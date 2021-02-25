FROM alpine:latest

RUN apk add --no-cache \
	curl \
	tar \
	wget

# add s6 overlay
RUN cd /tmp \
  && curl -s https://api.github.com/repos/just-containers/s6-overlay/releases/latest | \
  grep "browser_download_url.*s6-overlay-amd64-installer" | \
  cut -d ":" -f 2,3 | tr -d \" | \
  wget -qi -

RUN chmod +x /tmp/s6-overlay-amd64-installer && /tmp/s6-overlay-amd64-installer / && rm /tmp/s6-overlay-amd64-installer

RUN \
 echo "**** install runtime packages ****" && \
 apk add --no-cache \
	bash \
	ca-certificates \
	coreutils \
	procps \
	shadow \
	tzdata \
	nano \ 
	libc6-compat && \
	curl -s -O https://bin.equinox.io/c/VdrWdbjqyF/cloudflared-stable-linux-amd64.tgz \
        && tar zxf cloudflared-stable-linux-amd64.tgz \
        && mv cloudflared /bin \
        && rm cloudflared-stable-linux-amd64.tgz && \
 rm -rf \
	/tmp/*

# add local files
COPY root/ /
VOLUME ["/argo"]

ENTRYPOINT ["/init"]
