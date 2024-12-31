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

export ADDRESS_10001=ray://head.process.${FLY_APP_NAME}.internal:10001
export ADDRESS_6379=head.process.${FLY_APP_NAME}.internal:6379
export VLLM_HOST_IP=${FLY_MACHINE_ID}.vm.${FLY_APP_NAME}.internal
export RAY_OVERRIDE_DASHBOARD_URL="https://${FLY_APP_NAME}.fly.dev:8265"
export RAY_DEFAULT_OBJECT_STORE_MAX_MEMORY_BYTES=$((10 * 1024 * 1024 * 1024))
export RAY_ENABLE_RECORD_ACTOR_TASK_LOGGING=1

# A bunch of attempts to workaround multi node communications
#export NCCL_P2P_DISABLE=1
export NCCL_SOCKET_IFNAME=eth0, NCCL_SOCKET_FAMILY=AF_INET6
#export VLLM_USE_RAY_SPMD_WORKER=1 VLLM_USE_RAY_COMPILED_DAG=1

# Model specific parameters
: ${MODEL:=facebook/opt-125m}
MODEL_ARGS=("--model=$MODEL")
case $MODEL in
facebook/opt-125m)
  MODEL_ARGS+=("--max-model-len=2048" "--chat-template=/app/chatml.jinja" "--tensor-parallel-size=2" "--pipeline-parallel-size=1")
  ;;
deepseek-ai/DeepSeek-V3)
  MODEL_ARGS+=("--max-model-len=8192" "--tensor-parallel-size=8" "--pipeline-parallel-size=2")
  ;;
esac

case $1 in
head)
  ray start --head \
    --num-cpus 0 --num-gpus 0 \
    --node-ip-address "$VLLM_HOST_IP" \
    --dashboard-host "127.0.0.1" \
    --dashboard-port 8266
  exec socat TCP6-LISTEN:8265,fork,reuseaddr TCP4:127.0.0.1:8266
  ;;
oapi)
  huggingface-cli download "$MODEL"
  ray start \
    --num-cpus 8 --num-gpus 8 \
    --metrics-export-port 9091 \
    --address "$ADDRESS_6379" --node-ip-address "$VLLM_HOST_IP"

  export RAY_ADDRESS=$ADDRESS_6379
  exec python3 -m vllm.entrypoints.openai.api_server \
    --port 8000 \
    --trust-remote-code \
    --swap-space 8 \
    --cpu-offload-gb 32 \
    --gpu-memory-utilization 0.9 \
    --enforce-eager \
    --disable-custom-all-reduce \
    --disable-async-output-proc \
    --task generate \
    --distributed-executor-backend ray \
    "${MODEL_ARGS[@]}"
  ;;
worker)
  huggingface-cli download "$MODEL"
  ray start \
    --num-cpus 8 --num-gpus 8 \
    --metrics-export-port 9091 \
    --address "$ADDRESS_6379" --node-ip-address "$VLLM_HOST_IP"
  # export PYTORCH_NO_CUDA_MEMORY_CACHING=1
  exec sleep inf
  ;;
esac
