ARG VARIANT_VERSION=0.35.1
ARG UNICONF_VERSION=0.1.7
ARG GOMPLATE_VERSION=v3.5.0
ARG YQ_VERSION=2.4.0

FROM aroq/variant:$VARIANT_VERSION as variant
FROM aroq/uniconf:$UNICONF_VERSION as uniconf
FROM hairyhenderson/gomplate:$GOMPLATE_VERSION as gomplate
FROM mikefarah/yq:$YQ_VERSION as yq

# Self-reference to avoid rebuilding on each build:
FROM aroq/toolbox:latest as toolbox

FROM golang:1-alpine as builder

# Install alpine package manifest
COPY Dockerfile.packages.builder.txt /etc/apk/packages.txt
RUN apk add --no-cache --update $(grep -v '^#' /etc/apk/packages.txt)

FROM alpine:3.10.1
COPY --from=yq /usr/bin/yq /usr/bin/yq
COPY --from=variant /usr/bin/variant /usr/bin/
COPY --from=gomplate /gomplate /usr/bin/
COPY --from=uniconf /uniconf/uniconf /usr/bin/uniconf
COPY --from=toolbox /usr/bin/go-getter /usr/bin

# Install alpine package manifest
COPY Dockerfile.packages.txt /etc/apk/packages.txt
RUN apk add --no-cache --update $(grep -v '^#' /etc/apk/packages.txt)

# Add git-secret package from edge testing
RUN apk add --no-cache -X http://dl-cdn.alpinelinux.org/alpine/edge/testing git-secret

RUN mkdir -p /usr/toolbox/deps/toolbox
COPY ./* /usr/toolbox/deps/toolbox
