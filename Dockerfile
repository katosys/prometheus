#------------------------------------------------------------------------------
# Set the base image for subsequent instructions:
#------------------------------------------------------------------------------

FROM alpine:3.4
MAINTAINER Marc Villacorta Morera <marc.villacorta@gmail.com>

#------------------------------------------------------------------------------
# Environment variables:
#------------------------------------------------------------------------------

ENV GOPATH="/go" \
    VERSION="1.3.1"

#------------------------------------------------------------------------------
# Build and install:
#------------------------------------------------------------------------------

RUN apk add -U --no-cache -t dev git go make gcc musl-dev \
    && mkdir -p ${GOPATH}/src/github.com/prometheus \
    && cd ${GOPATH}/src/github.com/prometheus \
    && git clone https://github.com/prometheus/prometheus.git \
    && cd prometheus && git checkout v${VERSION} -b build \
    && make build && mv prometheus promtool /usr/local/bin \
    && mkdir /etc/prometheus /usr/share/prometheus \
    && mv console* /usr/share/prometheus \
    && ln -s /usr/share/prometheus/console* /etc/prometheus \
    && apk del --purge dev && rm -rf /tmp/* /go

#------------------------------------------------------------------------------
# Volumes:
#------------------------------------------------------------------------------

VOLUME [ "/etc/prometheus", \
         "/var/lib/prometheus" ]

#------------------------------------------------------------------------------
# Entrypoint and CMD:
#------------------------------------------------------------------------------

ENTRYPOINT [ "prometheus" ]
CMD        [ "-config.file=/etc/prometheus/prometheus.yml", \
             "-storage.local.path=/var/lib/prometheus", \
             "-web.console.libraries=/usr/share/prometheus/console_libraries", \
             "-web.console.templates=/usr/share/prometheus/consoles" ]
