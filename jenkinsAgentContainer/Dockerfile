# Jenkins Unix Agent Docker File
ARG java_version="11.0.15_10"
FROM --platform=linux/amd64 eclipse-temurin:${java_version}-jdk-alpine

ARG TARGETARCH
#ARG COMMIT_SHA

#Container env vars needed to be passed to container in env file
#JENKINS_JNLP_USERPW=agentuser:e8cf7e78ab1e3e06d7f4d45a68e0e3c82fa4df034432e2b16c0cfd10712c04c9
#JENKINS_URL=http://???????:8080
#JENKINS_NAME=Linux_Agent

# Jenkins vars
ARG jenkins_agent_version=4.8
    # jenkins.war checksum, download will be validated using it
#ARG jenkins_sha256=d193f179aadf3a7ceb61adebc3ab51218ac4a7852b88932ff33b44fd7be6010f
    # Can be used to customize where jenkins.war get downloaded from
ARG jenkins_jar_url=https://repo.jenkins-ci.org/public/org/jenkins-ci/main/remoting/${jenkins_agent_version}/remoting-${jenkins_agent_version}.jar
#ARG jenkins_jar_asc_url=https://repo.jenkins-ci.org/public/org/jenkins-ci/main/remoting/${jenkins_agent_version}/remoting-${jenkins_agent_version}.jar.asc
#jenkins user and group vars
ARG user=jenkins
ARG group=jenkins
ARG uid=1000
ARG gid=1000
#jenkins folders  IMPORTANE the root is harded coded in the ENTRY POINT
ARG jenkins_agent_root=/apps/jenkins
ARG jenkins_agent_home=$jenkins_agent_root/jenkins_home
ARG agent_workdir=${jenkins_agent_home}/agent

#ARG ref=${jenkins_agent_root}/ref
#java vars
#ARG java_home=${jenkins_agent_root}/openjdk

ENV LANG='en_US.UTF-8' LANGUAGE='en_US:en' LC_ALL='en_US.UTF-8'
ENV JENKINS_AGENT_WORKDIR=${agent_workdir}
ENV JENKINS_ROOT=${jenkins_agent_root}

    #Install software on the container
RUN apk add --update --no-cache curl bash git git-lfs musl-locales openssh-client openssl procps  gnupg \
    # Create directories
    && mkdir -p ${jenkins_agent_home} \
    && mkdir -p ${jenkins_agent_root}/bin \
    && mkdir -p ${jenkins_agent_root}/scripts \
    && mkdir -p ${jenkins_agent_home}/.jenkins \
    && mkdir -p ${agent_workdir} \
    # Jenkins is run with user `jenkins`, uid = 1000
    # If you bind mount a volume from the host or a data container,
    # ensure you use the same uid
    && addgroup -g ${gid} ${group} \
    && adduser -h "${jenkins_agent_home}" -u ${uid} -G ${group} -D ${user} 

COPY jenkins-agent ${jenkins_agent_root}/scripts/jenkins-agent

    #Download the agent JAR and link it to slave.jar
    #COPY agent_pub.gpg "${jenkins_agent_root}/bin/agent_pub.gpg"
RUN curl -fsSL ${jenkins_jar_url} -o ${jenkins_agent_root}/bin/agent.jar \
    #&&  curl -fsSL ${jenkins_asc_jar_url} -o ${jenkins_agent_root}/bin/agent.asc \
    #&& gpg --no-tty --import "${jenkins_agent_root}/bin/agent_pub.gpg" \
    #&& gpg --verify ${jenkins_agent_root}/bin/agent.asc \
    # Remove software and files
    #---------------------------------------00sdfsfsdfsdfsdfsdfsdfsdfsdfsdfsdf RUN apk del --purge curl \
    #&& rm -rf ${jenkins_agent_root}/bin/agent.asc /root/.gnupg \
    && rm -rf /tmp/*.apk /tmp/gcc /tmp/gcc-libs.tar* /tmp/libz /tmp/libz.tar.xz /var/cache/apk/* \
    # Change owner to Jenkins..Jenkins Get access to these files and executte
    && chown -R  ${uid}:${gid} ${jenkins_agent_root} \
    && chmod -R u+rwx,g+rwx,o-rwx  ${jenkins_agent_root}

# set WORK Directory to Jenkins home
WORKDIR ${jenkins_agent_home}

#Set user jenkins
USER ${user}

# call jenkins_agent script
# Have to use ENTRYPOINT and NOT CMD for the agent
ENTRYPOINT [ "/apps/jenkins/scripts/jenkins-agent" ]
LABEL \
    Description="This is a base image, which provides the Jenkins agent executable (slave.jar)" Vendor="Jenkins project" Version="${jenkins_agent_version}" \
    org.opencontainers.image.vendor="Jenkins project" \
    org.opencontainers.image.title="Robb's Jenkins Agent Base Docker image" \
    org.opencontainers.image.description="This is a base image, which provides the Jenkins agent executable Linux (agent.jar)" \
    org.opencontainers.image.version="${jenkins_agent_version}" \
    org.opencontainers.image.url="https://www.jenkins.io/" \
    org.opencontainers.image.source="https://github.com/jenkinsci/docker-agent" \
    org.opencontainers.image.licenses="MIT"