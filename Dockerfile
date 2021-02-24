FROM alpine:latest

RUN apk add --no-cache \
	curl \
	wget

# add s6 overlay
RUN cd /tmp \
  && curl -s https://api.github.com/repos/just-containers/s6-overlay/releases/latest | \
  grep "browser_download_url.*s6-overlay-amd64-installer\.tar\.gz" | \
  cut -d ":" -f 2,3 | tr -d \" | \
  wget -qi -
RUN tar xzf /tmp/s6-overlay-amd64.tar.gz -C / --exclude="./bin" --exclude="./sbin" \
&& tar xzf /tmp/s6-overlay-amd64.tar.gz -C /usr ./bin ./sbin \

COPY patch/ /tmp/patch

# environment variables
ENV PS1="$(whoami)@$(hostname):$(pwd)\\$ " \
HOME="/root" \
TERM="xterm"

RUN \
 echo "**** install build packages ****" && \
 apk add --no-cache --virtual=build-dependencies \
	curl \
	patch \
	tar && \
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
 echo "**** create abc user and make our folders ****" && \
 groupmod -g 1000 users && \
 useradd -u 911 -U -d /config -s /bin/false abc && \
 usermod -G users abc && \
 mkdir -p \
	/app \
	/config \
	/defaults && \
 mv /usr/bin/with-contenv /usr/bin/with-contenvb && \
 patch -u /etc/s6/init/init-stage2 -i /tmp/patch/etc/s6/init/init-stage2.patch && \
 echo "**** cleanup ****" && \
 apk del --purge \
	build-dependencies && \
 rm -rf \
	/tmp/*

# add local files
COPY root/ /
VOLUME ["/argo"]

ENTRYPOINT ["/init"]
