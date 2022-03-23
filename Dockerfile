FROM alpine:3.15.2
RUN apk update && \
        apk add --no-cache \
		dhcrelay=4.4.2_p1-r1
EXPOSE 67 67/udp
ENTRYPOINT ["dhcrelay", "-d"]
LABEL maintainer="Alex Lane"