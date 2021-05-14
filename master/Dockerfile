FROM debian:buster-slim as powerdns
LABEL maintainer="Tinashe Chikomo"

ENV NAME=dnsdist \
    DNSDIST_VERSION=master \
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

RUN DEBIAN_FRONTEND=noninteractive apt-get update && apt-get install -y curl gnupg sudo apt-utils

ADD ${DNSDIST_VERSION}/pdns.list /etc/apt/sources.list.d/pdns.list
ADD ${DNSDIST_VERSION}/dnsdist /etc/apt/preferences.d/dnsdist

RUN curl https://repo.powerdns.com/CBC8B383-pub.asc | sudo apt-key add - && \
    set -x && \
     DEBIAN_FRONTEND=noninteractive apt-get update && apt-get install -y --no-install-recommends \
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
