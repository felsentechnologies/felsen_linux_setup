#!/usr/bin/env bash
# Felsen installer module. Loaded by lib/bootstrap.sh.

minio.bucket.setup() {
  dados
  pegar_senha_minio

  ADMIN_USER="$user_minio"
  ADMIN_PASS="$senha_minio"

  MINIO_CONTAINER=$(docker ps --filter "name=minio" -q | head -n1)
  if [ -z "$MINIO_CONTAINER" ]; then
    echo "a Container MinIO nAo encontrado!"
    exit 1
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
    echo -e "\na Falha ao conectar com os endpoints padrao (minio, localhost)."
    echo -en "\e[33m Digite manualmente o endpoint (ex: http://ip:9000): \e[0m"
    read -r S3_ENDPOINT

    $MC_CMD alias set admin "$S3_ENDPOINT" "$ADMIN_USER" "$ADMIN_PASS" || {
      echo "a Ainda nAo foi possivel conectar. Verifique o endpoint e tente novamente."
      exit 1
    }
    echo " Conectado com sucesso ao MinIO via $S3_ENDPOINT"
  fi

  echo -e "\n\e[97mPasso$amarelo 1/1\e[0m"
  echo -en "\e[33mDigite o nome do Bucket (ex: arquivos): \e[0m"
  read -r BUCKET
  echo ""


  if $MC_CMD ls admin/"$BUCKET" >/dev/null 2>&1; then
    echo "ai Bucket '$BUCKET' jA existe, continuando..."
  else
    if $MC_CMD mb admin/"$BUCKET"; then
      echo " Bucket '$BUCKET' criado com sucesso!"
    else
      echo "ai Falha ao criar bucket '$BUCKET', mas continuando..."
    fi
  fi


  if $MC_CMD anonymous set public admin/"$BUCKET"; then
    echo " Politica 'public' aplicada ao bucket '$BUCKET'"
  else
    echo "ai Falha ao aplicar politica pAoblica ao bucket '$BUCKET'"
  fi


  S3_ACCESS_KEY=$(head /dev/urandom | tr -dc A-Z0-9 | head -c 20)
  S3_SECRET_KEY=$(head /dev/urandom | tr -dc A-Za-z0-9 | head -c 40)

  if $MC_CMD admin user add admin "$S3_ACCESS_KEY" "$S3_SECRET_KEY"; then
    echo " Usuario criado com sucesso!"
  else
    echo "a Erro ao criar usuario"
    exit 1
  fi

  if $MC_CMD admin policy attach admin readwrite --user "$S3_ACCESS_KEY"; then
    echo " Politica 'readwrite' anexada ao usuario $S3_ACCESS_KEY"
  else
    echo "ai Falha ao anexar politica ao usuario"
  fi

  $MC_CMD alias set myminio "$S3_ENDPOINT" "$S3_ACCESS_KEY" "$S3_SECRET_KEY"
  $MC_CMD ls myminio/"$BUCKET" || echo "ai Falha ao listar bucket"

   echo ""
   echo -e "\e[32m[ BUCKET $BUCKET ]\e[0m"
   echo ""
   echo -e "\e[33mS3 Endpoint:\e[97m $S3_ENDPOINT\e[0m"
   echo ""
   echo -e "\e[33mNome da Bucket:\e[97m $BUCKET\e[0m"
   echo ""
   echo -e "\e[33mAccess Key:\e[97m $S3_ACCESS_KEY\e[0m"
   echo ""
   echo -e "\e[33mSecret Key:\e[97m $S3_SECRET_KEY\e[0m"
 
   creditos_msg
   requisitar_outra_instalacao
}


