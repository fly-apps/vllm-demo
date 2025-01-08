#!/bin/bash
ulimit -n 102400

[[ $MODEL ]] || exit 1

VLLMSERVE_ARGS=("--model=$MODEL")
case $MODEL in
facebook/opt-125m)
  VLLMSERVE_ARGS+=("--max-model-len=2048" "--chat-template=/app/chatml.jinja" "--tensor-parallel-size=2" "--pipeline-parallel-size=1")
  VLLMSERVE_ARGS+=(--enforce-eager --disable-custom-all-reduce --disable-async-output-proc)
  VLLMSERVE_ARGS+=(--distributed-executor-backend=ray)
  ;;
deepseek-ai/DeepSeek-V3)
  VLLMSERVE_ARGS+=("--max-model-len=8192" "--tensor-parallel-size=8" "--pipeline-parallel-size=2")
  VLLMSERVE_ARGS+=(--enforce-eager --disable-custom-all-reduce --disable-async-output-proc)
  VLLMSERVE_ARGS+=(--distributed-executor-backend=ray)
  ;;
OPEA/DeepSeek-V3-int4-sym-gptq-inc)
  VLLMSERVE_ARGS+=(--served-model-name=deepseek-ai/DeepSeek-V3)
  VLLMSERVE_ARGS+=(--tensor-parallel-size=8)
  VLLMSERVE_ARGS+=(--max-parallel-loading-workers=1)
  VLLMSERVE_ARGS+=(--enforce-eager --disable-custom-all-reduce --disable-async-output-proc)
  VLLMSERVE_ARGS+=(--swap-space=4 --cpu-offload-gb=0 --gpu-memory-utilization=0.8)
  VLLMSERVE_ARGS+=(--max-model-len=16384 --max_num_seqs=1)
  #VLLMSERVE_ARGS+=(-q gptq)
  ;;
cognitivecomputations/DeepSeek-V3-AWQ)
  VLLMSERVE_ARGS+=(--served-model-name=deepseek-ai/DeepSeek-V3)
  VLLMSERVE_ARGS+=(--tensor-parallel-size=8)
  VLLMSERVE_ARGS+=(--enforce-eager --disable-custom-all-reduce --disable-async-output-proc)
  VLLMSERVE_ARGS+=(--swap-space=4 --cpu-offload-gb=0 --gpu-memory-utilization=0.8)
  VLLMSERVE_ARGS+=(--max-model-len=16384 --max_num_seqs=1)
  ;;
esac

exec python3 -m vllm.entrypoints.openai.api_server --port 8000 \
  --trust-remote-code \
  --task generate \
  "${VLLMSERVE_ARGS[@]}"
