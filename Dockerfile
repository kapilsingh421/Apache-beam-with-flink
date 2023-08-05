FROM apache/flink:1.16.2-scala_2.12-java11
ARG FLINK_VERSION=1.16.2
ARG KAFKA_VERSION=2.8.0

# Install python3.7 and pyflink
RUN set -ex; \
  apt-get update && \
  apt-get install -y build-essential libssl-dev zlib1g-dev libbz2-dev libffi-dev lzma liblzma-dev && \
  wget https://www.python.org/ftp/python/3.7.9/Python-3.7.9.tgz && \
  tar -xvf Python-3.7.9.tgz && \
  cd Python-3.7.9 && \
  ./configure --without-tests --enable-shared && \
  make -j4 && \
  make install && \
  ldconfig /usr/local/lib && \
  cd .. && rm -f Python-3.7.9.tgz && rm -rf Python-3.7.9 && \
  ln -s /usr/local/bin/python3 /usr/local/bin/python && \
  ln -s /usr/local/bin/pip3 /usr/local/bin/pip && \
  apt-get clean && \
  rm -rf /var/lib/apt/lists/* && \
  python -m pip install --upgrade pip; \
  pip install apache-flink==${FLINK_VERSION}; \
  pip install kafka-python

# Download required JARs
RUN wget -P /opt/flink/lib/ https://repo.maven.apache.org/maven2/org/apache/flink/flink-connector-kafka/1.16.2/flink-connector-kafka-1.16.2.jar; \
    wget -P /opt/flink/lib/ https://repo.maven.apache.org/maven2/org/apache/flink/flink-shaded-jackson/2.13.4-16.1/flink-shaded-jackson-2.13.4-16.1.jar; \
    wget -P /opt/flink/lib/ https://repo.maven.apache.org/maven2/org/apache/flink/flink-protobuf/${FLINK_VERSION}/flink-protobuf-${FLINK_VERSION}.jar; \
    wget -P /opt/flink/lib/ https://repo.maven.apache.org/maven2/org/apache/flink/flink-python/${FLINK_VERSION}/flink-python-${FLINK_VERSION}.jar; \
    wget -P /opt/flink/lib/ https://repo1.maven.org/maven2/org/apache/kafka/kafka-clients/${KAFKA_VERSION}/kafka-clients-${KAFKA_VERSION}.jar; \
    wget -P /opt/flink/lib/ https://repo.maven.apache.org/maven2/org/apache/flink/flink-rpc-akka-loader/${FLINK_VERSION}/flink-rpc-akka-loader-${FLINK_VERSION}.jar; \
    wget -P /opt/flink/lib/ https://repo1.maven.org/maven2/org/apache/beam/beam-sdks-java-core/2.31.0/beam-sdks-java-core-2.31.0.jar; \
    wget -P /opt/flink/lib/ https://repo.maven.apache.org/maven2/org/apache/flink/flink-sql-connector-kafka/${FLINK_VERSION}/flink-sql-connector-kafka-${FLINK_VERSION}.jar; \
    wget -P /opt/flink/lib/ https://repo.maven.apache.org/maven2/org/apache/flink/flink-sql-json/1.16.2/flink-sql-json-1.16.2.jar; \
    wget -P /opt/flink/lib/ https://repo.maven.apache.org/maven2/org/apache/flink/flink-shaded-jackson-module-jsonSchema/2.13.4-16.1/flink-shaded-jackson-module-jsonSchema-2.13.4-16.1.jar; \
    wget -P /opt/flink/lib/ https://repo.maven.apache.org/maven2/org/apache/flink/flink-format-common/1.16.2/flink-format-common-1.16.2-javadoc.jar; \
    wget -P /opt/flink/lib/ https://repo1.maven.org/maven2/com/fasterxml/jackson/core/jackson-databind/2.12.3/jackson-databind-2.12.3.jar; \
    wget -P /opt/flink/lib/ https://repo1.maven.org/maven2/org/apache/beam/beam-sdks-java-core/2.49.0/beam-sdks-java-core-2.49.0.jar

# Install SDK. (needed for Python SDK)
RUN pip install --no-cache-dir apache-beam[gcp]

# Copy files from official SDK image, including script/dependencies.
COPY --from=apache/beam_python3.7_sdk:2.48.0 /opt/apache/beam/ /opt/apache/beam/

# java SDK
COPY --from=apache/beam_java11_sdk:2.48.0 /opt/apache/beam/ /opt/apache/beam_java/
