FROM briangxchen/collectd:latest as collectd

FROM maven:3.6.3-jdk-8-openj9 as builder

WORKDIR /build

COPY . ./
RUN mvn -ff package -DskipTests -Dmaven.wagon.http.ssl.insecure=true -Dmaven.wagon.http.ssl.allowall=true -Dmaven.wagon.http.ssl.ignore.validity.dates=true

RUN mkdir -p /mcac/lib

RUN cp /build/target/datastax-mcac-agent-*.jar /mcac/lib

COPY --from=collectd /collectd/ /mcac/lib/collectd
#RUN cp -r /build/target/collectd /mcac/lib

