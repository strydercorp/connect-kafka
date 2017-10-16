# connect-kafka

This is forked from: https://github.com/segment-integrations/connect-kafka

To listen on Segment webhook events, and forward them onto Kafka.

## Quickstart

1. Install and Set-up Go
```bash
brew install go
mkdir ~/go
```

2. download this repo
```bash
cd ~/go
go get -d github.com/strydercorp/connect-kafka 
```

3. build binary and docker image
```bash
cd ~/go/src/github.com/strydercorp/connect-kafka
make docker
```

4. run locally

5. push to Heroku
If you haven't logged in:
```
heroku container:login
```
Then
```
heroku container:push web -a handshake-seg2kafka-staging
```
