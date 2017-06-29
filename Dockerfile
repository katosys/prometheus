#------------------------------------------------------------------------------
# Set the base image for subsequent instructions:
#------------------------------------------------------------------------------

FROM golang:1.8-alpine
MAINTAINER Marc Villacorta Morera <marc.villacorta@gmail.com>

#------------------------------------------------------------------------------
# Environment variables:
#------------------------------------------------------------------------------

ENV VERSION="1.7.1"

#------------------------------------------------------------------------------
# Build and install:
#------------------------------------------------------------------------------

RUN apk add -U --no-cache -t dev git make gcc musl-dev \
    && mkdir -p ${GOPATH}/src/github.com/prometheus \
    && cd ${GOPATH}/src/github.com/prometheus \
    && git clone https://github.com/prometheus/prometheus.git \
    && cd prometheus && git checkout v${VERSION} -b build \
    && make build && mv prometheus promtool /usr/local/bin \
    && mkdir /etc/prometheus /usr/share/prometheus \
    && mv console* /usr/share/prometheus \
    && ln -s /usr/share/prometheus/console* /etc/prometheus \
    && cp documentation/examples/prometheus.yml /etc/prometheus \
    && apk del --purge dev && rm -rf /tmp/* /go /usr/local/go

#------------------------------------------------------------------------------
# Volumes:
#------------------------------------------------------------------------------

VOLUME [ "/etc/prometheus", \
         "/var/lib/prometheus" ]

#------------------------------------------------------------------------------
# Entrypoint and CMD:
#------------------------------------------------------------------------------

WORKDIR    "/"
EXPOSE     9090
ENTRYPOINT [ "prometheus" ]
CMD        [ "-config.file=/etc/prometheus/prometheus.yml", \
             "-storage.local.path=/var/lib/prometheus", \
             "-web.console.libraries=/etc/prometheus/console_libraries", \
             "-web.console.templates=/etc/prometheus/consoles" ]
