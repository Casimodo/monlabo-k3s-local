FROM --platform=linux/amd64 ubuntu:24.04

ARG CFX_SERVER_DOWNLOAD_URL

RUN apt-get update \
    && apt-get install --yes --no-install-recommends ca-certificates curl libatomic1 xz-utils \
    && test -n "$CFX_SERVER_DOWNLOAD_URL" \
    && curl --fail --location "$CFX_SERVER_DOWNLOAD_URL" --output /tmp/cfx.tar.xz \
    && mkdir -p /opt/cfx \
    && tar -xJf /tmp/cfx.tar.xz -C /opt/cfx \
    && rm -rf /tmp/cfx.tar.xz /var/lib/apt/lists/*

COPY --chmod=755 entrypoint.sh /usr/local/bin/cfx-entrypoint

WORKDIR /server-data
EXPOSE 30120/tcp 30120/udp
ENTRYPOINT ["cfx-entrypoint"]