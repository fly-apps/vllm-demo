#!/bin/bash

. /app/env.sh

export RAY_ADDRESS=ray://$HEAD_FQDN:10001
export VLLM_USE_RAY_SPMD_WORKER=1 VLLM_USE_RAY_COMPILED_DAG=1

[[ $MODEL ]] || exit 1

VLLMSERVE_ARGS=("--model=$MODEL")
case $MODEL in
facebook/opt-125m)
  VLLMSERVE_ARGS+=("--max-model-len=2048" "--chat-template=/app/chatml.jinja" "--tensor-parallel-size=2" "--pipeline-parallel-size=1")
  ;;
deepseek-ai/DeepSeek-V3)
  VLLMSERVE_ARGS+=("--max-model-len=8192" "--tensor-parallel-size=8" "--pipeline-parallel-size=2")
  ;;
esac

VLLMSERVE_ARGS+=(--enforce-eager --disable-custom-all-reduce --disable-async-output-proc)

exec python3 -m vllm.entrypoints.openai.api_server \
  --port 8000 \
  --trust-remote-code \
  --swap-space 8 --cpu-offload-gb 32 --gpu-memory-utilization 0.9 \
  --distributed-executor-backend ray \
  --task generate \
  "${VLLMSERVE_ARGS[@]}"
