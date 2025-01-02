FROM vllm/vllm-openai:v0.6.6.post1
RUN apt-get update -qq && apt-get install -qy net-tools iproute2 tcpdump socat
RUN pip install ray[adag]
ADD entrypoint.sh start-api.sh env.sh chatml.jinja /app/
ENTRYPOINT ["/app/entrypoint.sh"]
