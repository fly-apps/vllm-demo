FROM vllm/vllm-openai:v0.6.6.post1
RUN apt-get update -qq && apt-get install -qy net-tools iproute2 tcpdump socat
RUN pip install llmcompressor

# WARNING cuda.py:32] You are using a deprecated `pynvml` package. Please install `nvidia-ml-py` instead, and make sure to uninstall `pynvml`. 
RUN pip install nvidia-ml-py && pip uninstall -y pynvml

RUN pip install huggingface_hub[cli]

# Silence "Waiting for output .." debug messages printed every 10s
RUN sed -i -e '/Waiting for output/d' /usr/local/lib/python3.12/dist-packages/vllm/engine/multiprocessing/client.py

ADD *.sh *.py /app/
WORKDIR /app
ENTRYPOINT ["/app/entrypoint.sh"]
