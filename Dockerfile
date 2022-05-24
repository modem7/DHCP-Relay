FROM alpine:3.16.0
RUN apk update && \
        apk add --no-cache \
		dhcrelay=4.4.3-r0
EXPOSE 67 67/udp
ENTRYPOINT ["dhcrelay", "-d"]
LABEL maintainer="Alex Lane"