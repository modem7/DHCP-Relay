# syntax = docker/dockerfile:1

FROM alpine:3.16.1
RUN apk add --no-cache \
            dhcrelay=4.4.3-r0 \
            tzdata
EXPOSE 67 67/udp
# HEALTHCHECK CMD nc -uzvw3 127.0.0.1 67 || exit 1
ENTRYPOINT ["dhcrelay", "-d"]
LABEL maintainer="modem7"