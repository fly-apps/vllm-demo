#!/bin/bash
set -ex
ldconfig
ulimit -n 102400

bindmount() {
  mkdir -p {/data,}$1
  mount -o bind {/data,}$1
}
bindmount /root/.cache/huggingface

/app/start-api.sh &

exec sleep inf
