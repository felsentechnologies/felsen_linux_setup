#!/usr/bin/env bash
# Felsen installer module. Loaded by lib/bootstrap.sh.

minio.bucket() {
  dados
  pegar_senha_minio
  ADMIN_USER="$user_minio"
  ADMIN_PASS="$senha_minio"
  BUCKET_NAME="$1"

  if [ -z "$BUCKET_NAME" ]; then
    echo "AA' VocAAa precisa informar o nome do bucket. Exemplo: minio.bucket dify"
    return 1
  fi

  MINIO_CONTAINER=$(docker ps --filter "name=minio" -q | head -n1)
  if [ -z "$MINIO_CONTAINER" ]; then
    echo "AA' Container MinIO nAAo encontrado!"
    return 1
  fi

  MC_CMD="docker exec -i $MINIO_CONTAINER mc"
  S3_ENDPOINT=""
  ENDPOINTS=("http://minio:9000" "http://localhost:9000")

  for endpoint in "${ENDPOINTS[@]}"; do
    if $MC_CMD alias set admin "$endpoint" "$ADMIN_USER" "$ADMIN_PASS" >/dev/null 2>&1; then
      S3_ENDPOINT="$endpoint"
      echo " Conectado com sucesso ao MinIO via $S3_ENDPOINT"
      break
    fi
  done

  if [ -z "$S3_ENDPOINT" ]; then
    echo -e "\nAA' Falha ao conectar com os endpoints padrAAo (minio, localhost)."
    echo -en "\e[33m Digite manualmente o endpoint (ex: http://ip:9000): \e[0m"
    read -r S3_ENDPOINT
    $MC_CMD alias set admin "$S3_ENDPOINT" "$ADMIN_USER" "$ADMIN_PASS" || {
      echo "AA' Ainda nAAo foi possAAvel conectar. Verifique o endpoint e tente novamente."
      return 1
    }
    echo " Conectado com sucesso ao MinIO via $S3_ENDPOINT"
  fi

  if $MC_CMD mb admin/"$BUCKET_NAME"; then
    echo " Bucket '$BUCKET_NAME' criado com sucesso!"
  else
    echo "AAAAA  NAAo foi possAAvel criar o bucket '$BUCKET_NAME'. Ele jAA pode existir."
  fi

  if $MC_CMD anonymous set public admin/"$BUCKET_NAME"; then
    echo " Politica 'public' aplicada ao bucket '$BUCKET_NAME'"
  else
    echo "AAAAA  Falha ao aplicar polAAtica pAAoblica ao bucket '$BUCKET_NAME'"
  fi

  S3_ACCESS_KEY=$(head /dev/urandom | tr -dc A-Z0-9 | head -c 20)
  S3_SECRET_KEY=$(head /dev/urandom | tr -dc A-Za-z0-9 | head -c 40)

  if $MC_CMD admin user add admin "$S3_ACCESS_KEY" "$S3_SECRET_KEY"; then
    echo " Usuario criado com sucesso:"
    echo "Access Key: $S3_ACCESS_KEY"
    echo "Secret Key: $S3_SECRET_KEY"
  else
    echo "AA' Falha ao criar usuAArio no MinIO"
    return 1
  fi

  if $MC_CMD admin policy attach admin readwrite --user "$S3_ACCESS_KEY"; then
    echo " Politica 'readwrite' anexada ao usuario $S3_ACCESS_KEY"
  else
    echo "AAAAA  Falha ao anexar polAAtica ao usuAArio $S3_ACCESS_KEY"
  fi


  $MC_CMD ls admin || echo "AAAAA  Falha ao listar buckets no MinIO"

  export S3_ENDPOINT
  export S3_ACCESS_KEY
  export S3_SECRET_KEY
}

