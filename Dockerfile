FROM openjdk:8-jdk-alpine
MAINTAINER Cents for Change, L.L.C.

#Versions
ENV PIO_VERSION 0.11.0
ENV SPARK_VERSION 2.1.1
ENV ELASTICSEARCH_VERSION 5.4.1
ENV HBASE_VERSION 1.3.1
#Environment variables
ENV PIO_HOME /PredictionIO-${PIO_VERSION}-incubating
ENV PATH=${PIO_HOME}/bin:$PATH
ENV JAVA_HOME /usr/lib/jvm/java-8-openjdk-amd64

RUN apk add --update curl \
    libgfortran \
    build-base \
    bash \
  && rm -rf /var/cache/apk/*
#First get Predictionio
RUN curl -O http://mirror.nexcess.net/apache/incubator/predictionio/${PIO_VERSION}-incubating/apache-predictionio-${PIO_VERSION}-incubating.tar.gz \
    && mkdir predictionio-${PIO_VERSION} \
    && tar -xvzf apache-predictionio-${PIO_VERSION}-incubating.tar.gz -C predictionio-${PIO_VERSION} \
    && rm apache-predictionio-${PIO_VERSION}-incubating.tar.gz \
    && cd predictionio-${PIO_VERSION} \
    && ./make-distribution.sh
#Then build and extract
RUN tar zxvf predictionio-${PIO_VERSION}/PredictionIO-${PIO_VERSION}-incubating.tar.gz -C ${PIO_HOME} /
RUN rm -r predictionio-${PIO_VERSION}
RUN mkdir /${PIO_HOME}/vendors
COPY files/pio-env.sh ${PIO_HOME}/conf/pio-env.sh
#Spark is next, has hadoop 2.7
RUN curl -O http://d3kbcqa49mib13.cloudfront.net/spark-${SPARK_VERSION}-bin-hadoop2.7.tgz \
    && tar -xvzf spark-${SPARK_VERSION}-bin-hadoop2.7.tgz -C ${PIO_HOME}/vendors \
    && rm spark-${SPARK_VERSION}-bin-hadoop2.7.tgz

RUN curl -O https://download.elasticsearch.org/elasticsearch/elasticsearch/elasticsearch-${ELASTICSEARCH_VERSION}.tar.gz \
    && tar -xvzf elasticsearch-${ELASTICSEARCH_VERSION}.tar.gz -C ${PIO_HOME}/vendors \
    && rm elasticsearch-${ELASTICSEARCH_VERSION}.tar.gz \
    && echo 'cluster.name: primary' >> ${PIO_HOME}/vendors/elasticsearch-${ELASTICSEARCH_VERSION}/config/elasticsearch.yml \
    && echo 'network.host: 127.0.0.1' >> ${PIO_HOME}/vendors/elasticsearch-${ELASTICSEARCH_VERSION}/config/elasticsearch.yml

RUN curl -O http://archive.apache.org/dist/hbase/hbase-${HBASE_VERSION}/hbase-${HBASE_VERSION}-bin.tar.gz \
    && tar -xvzf hbase-${HBASE_VERSION}-bin.tar.gz -C ${PIO_HOME}/vendors \
    && rm hbase-${HBASE_VERSION}-bin.tar.gz
COPY files/hbase-site.xml ${PIO_HOME}/vendors/hbase-${HBASE_VERSION}/conf/hbase-site.xml
RUN sed -i "s|VAR_PIO_HOME|${PIO_HOME}|" ${PIO_HOME}/vendors/hbase-${HBASE_VERSION}/conf/hbase-site.xml \
    && sed -i "s|VAR_HBASE_VERSION|${HBASE_VERSION}|" ${PIO_HOME}/vendors/hbase-${HBASE_VERSION}/conf/hbase-site.xml
