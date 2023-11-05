
ARG CASSANDRA_VERSION=3.11.16
FROM riptano/collectd:latest as collectd
FROM maven:3.8.7-eclipse-temurin-11 as builder

ARG METRICS_COLLECTOR_VERSION=0.3.4
ARG METRICS_COLLECTOR_BUNDLE=${METRICS_COLLECTOR_VERSION}

WORKDIR /build

# Download QEMU, see https://github.com/docker/hub-feedback/issues/1261
ENV QEMU_URL https://github.com/balena-io/qemu/releases/download/v3.0.0%2Bresin/qemu-3.0.0+resin-aarch64.tar.gz
RUN curl -L ${QEMU_URL} | tar zxvf - -C . --strip-components 1

# Download and extract Metrics Collector
ENV MCAC_PATH /mcac
RUN mkdir -m 775 ${MCAC_PATH} && \
    if test ! -e datastax-mcac-agent-${METRICS_COLLECTOR_BUNDLE}.tar.gz; then curl -L -O "https://github.com/datastax/metric-collector-for-apache-cassandra/releases/download/v${METRICS_COLLECTOR_VERSION}/datastax-mcac-agent-${METRICS_COLLECTOR_BUNDLE}.tar.gz"; fi && \
    tar --directory ${MCAC_PATH} --strip-components 1 --gzip --extract --file datastax-mcac-agent-${METRICS_COLLECTOR_BUNDLE}.tar.gz && \
    chmod -R g+w ${MCAC_PATH}


FROM maven:3.6.3-jdk-11-slim as netty4150
RUN mvn dependency:get -DgroupId=io.netty -DartifactId=netty-all -Dversion=4.1.50.Final -Dtransitive=false

FROM cassandra:${CASSANDRA_VERSION} as oss41


LABEL maintainer="DataStax, Inc <info@datastax.com>"
LABEL name="Apache Cassandra"
LABEL vendor="DataStax, Inc"
LABEL release="${CASSANDRA_VERSION}"
LABEL summary="Apache Cassandra is an open source distributed database management system designed to handle large amounts of data across many commodity servers, providing high availability with no single point of failure. Cassandra offers robust support for clusters spanning multiple datacenters, with asynchronous masterless replication allowing low latency operations for all clients."
LABEL description="Apache Cassandra is an open source distributed database management system designed to handle large amounts of data across many commodity servers, providing high availability with no single point of failure. Cassandra offers robust support for clusters spanning multiple datacenters, with asynchronous masterless replication allowing low latency operations for all clients."

# Add QEMU
COPY --from=builder /build/qemu-aarch64-static /usr/bin

ENV MCAC_PATH /mcac

RUN mkdir -m 775 ${MCAC_PATH}
COPY --from=builder --chown=cassandra:root ${MCAC_PATH} ${MCAC_PATH}

COPY --from=collectd /collectd/ /mcac/lib/collectd

# Netty arm64 epoll support was not added until 4.1.50 (https://github.com/netty/netty/pull/9804)
# Only replace this dependency for arm64 to avoid regressions
RUN rm /opt/cassandra/lib/netty-all-*.jar
COPY --from=netty4150 --chown=cassandra:root /root/.m2/repository/io/netty/netty-all/4.1.50.Final/netty-all-4.1.50.Final.jar /opt/cassandra/lib/netty-all-4.1.50.Final.jar


