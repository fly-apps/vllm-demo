FROM vllm/vllm-openai:v0.6.6.post1
RUN apt-get update -qq && apt-get install -qy net-tools iproute2 tcpdump socat
RUN pip install ray[adag]
ADD *.sh *.py chatml.jinja /app/
WORKDIR /app
ENTRYPOINT ["/app/entrypoint.sh"]
