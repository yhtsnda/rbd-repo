FROM goodrainapps/openjdk:8u131-jdk-alpine

MAINTAINER zhouyq@goodrain.com

# Set vars
ENV ARTIFACTORY_USER_NAME=artifactory \
    ARTIFACTORY_USER_ID=1030 \
    ARTIFACTORY_HOME=/opt/jfrog/artifactory \
    ARTIFACTORY_DATA=/var/opt/jfrog/artifactory \
    RECOMMENDED_MAX_OPEN_FILES=32000 \
    MIN_MAX_OPEN_FILES=10000 \
    RECOMMENDED_MAX_OPEN_PROCESSES=1024 \
    POSTGRESQL_VERSION=9.4.1212

RUN apk add --no-cache tzdata wget curl bash su-exec && \
    cp /usr/share/zoneinfo/Asia/Shanghai /etc/localtime && \
    echo "Asia/Shanghai" >  /etc/timezone && \
    date && apk del --no-cache tzdata

ENV ARTIFACTORY_VER=6.5.9 \
    DOWNLOAD_URL="http://goodrain-pkg.oss-cn-shanghai.aliyuncs.com"
RUN mkdir -pv /opt/jfrog && \
    curl -q ${DOWNLOAD_URL}/artifactory-oss-${ARTIFACTORY_VER}.tar.gz | tar -xzC /opt/jfrog/ && \
    curl -q ${DOWNLOAD_URL}/data-6.5.9.tgz | tar -xzC /tmp

COPY entrypoint-artifactory.sh /
# Extract artifactory zip and create needed directories and softlinks
RUN mv ${ARTIFACTORY_HOME}*/ ${ARTIFACTORY_HOME}/ && \
    mv ${ARTIFACTORY_HOME}/etc ${ARTIFACTORY_HOME}/etc.orig/ && \
    rm -rf ${ARTIFACTORY_HOME}/logs && \
    addgroup -g ${ARTIFACTORY_USER_ID} ${ARTIFACTORY_USER_NAME} && \
    adduser -u ${ARTIFACTORY_USER_ID} -D -S -G ${ARTIFACTORY_USER_NAME} ${ARTIFACTORY_USER_NAME} && \
    chown -R ${ARTIFACTORY_USER_NAME}:${ARTIFACTORY_USER_NAME} ${ARTIFACTORY_HOME} && \
    chmod +x /entrypoint-artifactory.sh

# Default mounts. Should be passed in `docker run` or in docker-compose
VOLUME ${ARTIFACTORY_DATA}

# Expose Tomcat's port
EXPOSE 8081

ENV RELEASE_DESC=__RELEASE_DESC__

# Start the simple standalone mode of Artifactory
ENTRYPOINT /entrypoint-artifactory.sh
