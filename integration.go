package main

import (
	"crypto/tls"
	"crypto/x509"
	"io"
	"io/ioutil"
	"os"

	"github.com/Shopify/sarama"
	log "github.com/Sirupsen/logrus"
	"github.com/strydercorp/connect-kafka/internal/kafka"
	"github.com/tj/docopt"
)

type KafkaIntegration struct {
	topic    string
	producer sarama.SyncProducer
}

func (k *KafkaIntegration) newTLSFromConfig(m map[string]interface{}) *tls.Config {
	// https://github.com/heroku/heroku-kafka-demo-go
	roots := x509.NewCertPool()

	// TODO(john) add .env support
	TrustedCert := os.Getenv("KAFKA_TRUSTED_CERT")
	ClientCert := os.Getenv("KAFKA_CLIENT_CERT")
	ClientCertKey := os.Getenv("KAFKA_CLIENT_CERT_KEY")

	ok := roots.AppendCertsFromPEM([]byte(TrustedCert))
	if !ok {
		log.Fatal("Unable to parse Root Cert:", TrustedCert)
	}

	// Setup certs for Sarama
	cert, err := tls.X509KeyPair([]byte(ClientCert), []byte(ClientCertKey))
	if err != nil {
		log.Fatal(err)
	}

	tlsConfig := &tls.Config{
		Certificates:       []tls.Certificate{cert},
		InsecureSkipVerify: true,
		RootCAs:            roots,
	}

	tlsConfig.BuildNameToCertificate()
	return tlsConfig
}

func (k *KafkaIntegration) Init() error {
	m, err := docopt.Parse(usage, nil, true, Version, false)
	if err != nil {
		return err
	}

	kafkaConfig := &kafka.Config{BrokerAddresses: m["--broker"].([]string)}
	kafkaConfig.TLSConfig = k.newTLSFromConfig(m)

	producer, err := kafka.NewProducer(kafkaConfig)
	if err != nil {
		return err
	}

	k.producer = producer
	k.topic = m["--topic"].(string)

	return nil
}

func (k *KafkaIntegration) Process(r io.ReadCloser) error {
	defer r.Close()
	b, err := ioutil.ReadAll(r)
	if err != nil {
		return err
	}

	_, _, err = k.producer.SendMessage(&sarama.ProducerMessage{
		Topic: k.topic,
		Value: sarama.ByteEncoder(b),
	})

	return err
}
