#!/bin/bash
set -ex
ldconfig
ulimit -n 102400

bindmount() {
  mkdir -p {/data,}$1
  mount -o bind {/data,}$1
}
bindmount /tmp/ray
bindmount /root/.cache/huggingface

. /app/env.sh

case $1 in
head)
  ray start --head \
    --num-cpus 0 --num-gpus 0 \
    --node-ip-address "$NODE_FQDN" \
    --dashboard-host "127.0.0.1" --dashboard-port 8266
  exec socat TCP-LISTEN:8265,fork,reuseaddr TCP4:127.0.0.1:8266
  ;;
worker)
  huggingface-cli download "$MODEL"
  exec ray start \
    --block \
    --num-cpus 8 --num-gpus 8 \
    --metrics-export-port 9091 \
    --address "$GCS_ADDRESS" --node-ip-address "$NODE_FQDN"
  ;;
oapi)
  huggingface-cli download "$MODEL"
  rm -rf /tmp/ray/*
  #exec /app/start-api.sh
  exec sleep inf
  ;;
esac
