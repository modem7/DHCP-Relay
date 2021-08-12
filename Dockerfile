FROM alpine:3.14.0
RUN apk update
RUN apk add --no-cache dhcrelay
EXPOSE 67 67/udp
ENTRYPOINT ["dhcrelay", "-d"]
LABEL maintainer="Alex Lane"