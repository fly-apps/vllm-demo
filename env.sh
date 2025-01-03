#!/bin/bash
#
# Model specific parameters
export MODEL=${MODEL-=facebook/opt-125m}

export NODE_FQDN=${FLY_MACHINE_ID}.vm.${FLY_APP_NAME}.internal
export HEAD_FQDN=head.process.${FLY_APP_NAME}.internal
export GCS_ADDRESS=$HEAD_FQDN:6379

export RAY_OVERRIDE_DASHBOARD_URL="https://${FLY_APP_NAME}.fly.dev:8265"
export RAY_DEFAULT_OBJECT_STORE_MAX_MEMORY_BYTES=$((10 * 1024 * 1024 * 1024))
export RAY_ENABLE_RECORD_ACTOR_TASK_LOGGING=1

export VLLM_HOST_IP=$NODE_FQDN
#export VLLM_USE_RAY_SPMD_WORKER=1 VLLM_USE_RAY_COMPILED_DAG=1

# A bunch of attempts to workaround multi node communications
export NCCL_P2P_DISABLE=1
export NCCL_SOCKET_IFNAME=eth0 NCCL_SOCKET_FAMILY=AF_INET6
export GLOO_SOCKET_IFNAME=eth0

# https://docs.vllm.ai/en/stable/getting_started/debugging.html#enable-more-logging
export VLLM_LOGGING_LEVEL=DEBUG
export NCCL_DEBUG=DEBUG # TRACE

# export PYTORCH_NO_CUDA_MEMORY_CACHING=1
