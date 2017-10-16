#!/usr/bin/env bash

if [[ -z $KAFKA_URL ]] || [[ -z $KAFKA_TRUSTED_CERT ]] || [[ -z $KAFKA_CLIENT_CERT ]] || [[ -z $KAFKA_CLIENT_CERT_KEY ]]; then
  echo "These environment variables must be set: KAFKA_URL, KAFKA_TRUSTED_CERT, KAFKA_CLIENT_CERT, KAFKA_CLIENT_CERT_KEY" && exit 1
fi

KAFKA_TOPIC=${KAFKA_TOPIC:-segment_events}

# https://github.com/segmentio/connect/blob/master/integration.go
LISTEN_ADDRESS=localhost:${PORT:-3000}
echo "Will Listen on ${LISTEN_ADDRESS}"
echo ""

CMD="/connect-kafka"
CMD+=" --topic=$KAFKA_TOPIC"

for broker_url in `echo $KAFKA_URL | tr ',' ' '`; do
  CMD+=" --broker=$broker_url"
done

echo "Executing: $CMD"

$CMD
