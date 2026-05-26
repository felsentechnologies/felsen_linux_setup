#!/usr/bin/env bash
# Felsen installer module. Loaded by lib/bootstrap.sh.

minio.bucket.delete() {
  echo -en "\e[33m Digite o nome da Bucket que deseja remover (ex: arquivos): \e[0m"
  read -r BUCKET

  POLICY_NAME="publicread-$BUCKET"

  # Descobre o container do MinIO
  MINIO_CONTAINER=$(docker ps --filter "name=minio" -q | head -n1)
  if [ -z "$MINIO_CONTAINER" ]; then
    echo "Container MinIO nao encontrado!"
    exit 1
  fi

  MC_CMD="docker exec -i $MINIO_CONTAINER mc"

  echo -e "\nBuscando usuario vinculado a politica $POLICY_NAME..."
  USER_ACCESS_KEY=$($MC_CMD admin policy entities admin "$POLICY_NAME" 2>/dev/null | grep -oP '(?<=user\s)[^\s]+')

  if [ -z "$USER_ACCESS_KEY" ]; then
    echo "Nao foi possivel encontrar o usuario com a politica '$POLICY_NAME'."
    exit 1
  fi

  echo " Usuario identificado: $USER_ACCESS_KEY"

  echo -e "\n Limpando bucket, politica e usuario..."

  # Remove acesso anonimo
  $MC_CMD anonymous set download admin/"$BUCKET" >/dev/null 2>&1 || echo "Falha ao remover acesso anonimo"

  # Remove o usuario
  $MC_CMD admin user remove admin "$USER_ACCESS_KEY" >/dev/null 2>&1 || echo "Falha ao remover usuario"

  # Remove a politica
  $MC_CMD admin policy remove admin "$POLICY_NAME" >/dev/null 2>&1 || echo "Falha ao remover politica"

  # Remove a bucket com todos os objetos
  $MC_CMD rb --force admin/"$BUCKET" >/dev/null 2>&1 || {
    echo "Falha ao remover a bucket. Verifique se ela existe e esta vazia."
    exit 1
  }

  echo -e "\n \e[32mBucket '$BUCKET' e recursos associados removidos com sucesso!\e[0m"
}


## // ## // ## // ## // ## // ## // ## // ## //## // ## // ## // ## // ## // ## // ## // ## // ##
##                                         FELSEN SETUP                                        ##
## // ## // ## // ## // ## // ## // ## // ## //## // ## // ## // ## // ## // ## // ## // ## // ##


