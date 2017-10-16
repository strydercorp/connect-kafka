FROM ubuntu

RUN mkdir /certs
COPY internal/docker/entrypoint.sh /entrypoint.sh
COPY target/connect-kafka-linux-amd64 /connect-kafka

CMD ["/entrypoint.sh"]
