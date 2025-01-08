#!/bin/bash
set -ex
ldconfig
ulimit -n 102400

bindmount() {
  mkdir -p {/data,}$1
  mount -o bind {/data,}$1
}
bindmount /root/.cache/huggingface

sed -i -e '/Waiting for output/d' /usr/local/lib/python3.12/dist-packages/vllm/engine/multiprocessing/client.py

/app/start-api.sh &

exec sleep inf
