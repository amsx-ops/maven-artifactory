FROM maven:3.6.2-jdk-11

ENV VERSION=1.28.0

RUN apt-get update && apt-get install -y \
    jq \
    bash \
    curl \
    wget \
    git \
 && rm -rf /var/lib/apt/lists/*

RUN wget https://dl.bintray.com/jfrog/jfrog-cli-go/$VERSION/jfrog-cli-linux-386/jfrog

RUN chmod +x jfrog && mv jfrog /usr/bin/

ENV M2_HOME=/usr/share/maven

COPY pipe /usr/bin/
