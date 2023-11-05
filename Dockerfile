FROM riptano/collectd:latest as collectd

FROM maven:3.6.3-jdk-8-openj9 as builder

WORKDIR /build

COPY . ./
RUN mvn -ff package -DskipTests

RUN mkdir -p /mcac/lib

RUN cp /build/target/datastax-mcac-agent-*.jar /mcac/lib

COPY --from=collectd /collectd/ /mcac/lib/collectd
#RUN cp -r /build/target/collectd /mcac/lib

