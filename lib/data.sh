#!/usr/bin/env bash

DATA_DIR="${DATA_DIR:-${HOME}/dados_vps}"

data_dir() {
  printf '%s\n' "$DATA_DIR"
}

data_file() {
  printf '%s/%s\n' "$DATA_DIR" "$1"
}

ensure_data_dir() {
  mkdir -p "$DATA_DIR"
}