FROM alpine:3.13 as rootfs-stage

# environment
ENV REL=v3.14
ENV ARCH=x86_64
ENV MIRROR=http://dl-cdn.alpinelinux.org/alpine
ENV PACKAGES=alpine-baselayout,\
alpine-keys,\
apk-tools,\
busybox,\
libc-utils,\
xz

# install packages
RUN \
 apk add --no-cache \
	bash \
	curl \
	tar \
	wget

# add s6 overlay
RUN cd /tmp \
  && curl -s https://api.github.com/repos/just-containers/s6-overlay/releases/latest | \
  grep "browser_download_url.*s6-overlay-amd64\.tar\.gz" | \
  cut -d ":" -f 2,3 | tr -d \" | \
  wget -qi - \
&& tarball="$(find . -name "*s6-overlay-amd64.tar.gz")" \
&& tar -xzf $tarball -C / \
&& mkdir -p /etc/fix-attrs.d \
&& mkdir -p /etc/services.d

RUN apk add --no-cache \
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
 rm -rf /tmp/*

VOLUME ["/argo"]

ENTRYPOINT ["/init"]
