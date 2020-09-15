FROM alpine:3.12

RUN apk add --update --no-cache \
        jq \
        gettext \
        curl \
        openssl \
        ca-certificates \
        bash \
        make

COPY discord.sh /usr/local/bin/discord
COPY slack.sh /usr/local/bin/slack
