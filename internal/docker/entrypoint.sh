#!/usr/bin/env bash

KAFKA_URL=`heroku config:get KAFKA_URL -a handshake-tracking-staging`
KAFKA_TRUSTED_CERT=`heroku config:get KAFKA_TRUSTED_CERT -a handshake-tracking-staging`
KAFKA_CLIENT_CERT=`heroku config:get KAFKA_CLIENT_CERT -a handshake-tracking-staging`
KAFKA_CLIENT_CERT_KEY=`heroku config:get KAFKA_CLIENT_CERT_KEY -a handshake-tracking-staging`

if [[ -z $KAFKA_URL ]] || [[ -z $KAFKA_TRUSTED_CERT ]] || [[ -z $KAFKA_CLIENT_CERT ]] || [[ -z $KAFKA_CLIENT_CERT_KEY ]]; then

  echo "These environment variables must be set: KAFKA_URL, KAFKA_TRUSTED_CERT, KAFKA_CLIENT_CERT, KAFKA_CLIENT_CERT_KEY" && exit 1
fi

KAFKA_TOPIC=${KAFKA_TOPIC:-segment_events}

echo $KAFKA_TRUSTED_CERT > /tmp/kafka_trusted_cert.cer
echo $KAFKA_CLIENT_CERT > /tmp/kafka_client_cert.cer
echo $KAFKA_CLIENT_CERT_KEY > /tmp/kafka_client_key_cert.cer

CMD="/connect-kafka"
CMD+=" --topic=$KAFKA_TOPIC"
CMD+=" --trusted-cert=/tmp/kafka_trusted_cert.cer"
CMD+=" --client-cert=/tmp/kafka_client_cert.cer"
CMD+=" --client-cert-key=/tmp/kafka_client_key_cert.cer"

if [[ ! -z $DEBUG ]]; then
  CMD+=" --debug"
fi

for broker_url in `echo $KAFKA_URL | tr ',' ' '`; do
  CMD+=" --broker=$broker_url"
done

echo "Executing: "
echo $CMD

$CMD
