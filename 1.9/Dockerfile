FROM debian:bookworm-slim AS powerdns
LABEL maintainer="Tinashe Chikomo"

ENV NAME=dnsdist \
    DNSDIST_VERSION=1.9 \
    VERSION=1.2 \
    SUMMARY="${NAME} is a highly DNS-, DoS- and abuse-aware loadbalancer." \
    DESCRIPTION="${NAME} is a highly DNS-, DoS- and abuse-aware loadbalancer."

ARG APT_KEY_DONT_WARN_ON_DANGEROUS_USAGE=1

LABEL summary="${SUMMARY}" \
      description="${DESCRIPTION}" \
      io.k8s.description="${DESCRIPTION}" \
      io.k8s.display-name="${NAME} ${DNSDIST_VERSION}" \
      name="hybridadmin/${NAME}" \
      maintainer="Tinashe Chikomo"

RUN set -x && DEBIAN_FRONTEND=noninteractive apt-get update -y && apt-get install -y apt-utils sudo curl gnupg2 && \
    echo "deb [signed-by=/etc/apt/keyrings/dnsdist-19-pub.asc] http://repo.powerdns.com/debian bookworm-dnsdist-19 main" | tee /etc/apt/sources.list.d/pdns.list && \
    printf "Package: pdns-*\nPin: origin repo.powerdns.com\nPin-Priority: 600" >> /etc/apt/preferences.d/dnsdist-19 && \
    mkdir -p /etc/apt/keyrings && curl https://repo.powerdns.com/FD380FBB-pub.asc | sudo tee /etc/apt/keyrings/dnsdist-19-pub.asc && \
    apt-get update -y && apt-get install -y --no-install-recommends \
      dnsdist \
      ldnsutils && \
    rm -rf \
        /tmp/* \
        /var/tmp/* \
        /var/lib/apt/lists/*

ADD docker-entrypoint.sh /usr/bin/docker-entrypoint.sh

RUN chmod a+x /usr/bin/docker-entrypoint.sh

EXPOSE 53/tcp
EXPOSE 53/udp

#VOLUME "/etc/dnsdist/"
WORKDIR "/etc/dnsdist/"

HEALTHCHECK --interval=5s --timeout=3s --start-period=5s CMD drill @127.0.0.1 cloudflare.com || exit 1
ENTRYPOINT ["docker-entrypoint.sh"]
CMD ["/usr/bin/dnsdist", "-u","_dnsdist", "-g", "_dnsdist" ,"--supervised"]
