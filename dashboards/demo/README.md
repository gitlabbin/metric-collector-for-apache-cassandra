### Cluster Demo

This docker-compose script starts a small cluster with some workloads running and the dashboards
in one easy command!

To use:  

  1. From the project root make the agent (in Windows, you will need to do this under WSL):
     
     ````
     mvn -DskipTests package
     ````
     
  2. From this directory start the system, noting we need to parse the mcac-agent.jar version from the pom (in Windows, do this outside of WSL):
     
     ````
     export PROJECT_VERSION=$(grep '<revision>' ../../pom.xml | sed -E 's/(<\/?revision>|[[:space:]])//g')
     docker-compose up
     
     docker-compose -f docker-compose-3.11.yml up --build
     
     docker-compose down -v
     ````
     
  3. Open your web browser to [http://localhost:3000](http://localhost:3000)
  
  If you want to change the jsonnet dashboards, make your changes then run:
  
  ````
  ../grafana/make-dashboards.sh
  ````
  
  Refresh the browser to see changes. 

## Running-MCAC-with-DSE 
https://datastax.my.site.com/support/s/article/Running-MCAC-with-DSE

```shell
MCAC_ROOT=/path/to/datastax-mcac-agent-0.3.3
JVM_OPTS="$JVM_OPTS -javaagent:${MCAC_ROOT}/lib/datastax-mcac-agent.jar"
JVM_OPTS="$JVM_OPTS -Djava.io.tmpdir=/path/to/new/tmp"

```

https://artifacts-zl.talend.com/nexus/content/groups/public/io/netty/netty-transport-native-epoll/4.1.98.Final/


