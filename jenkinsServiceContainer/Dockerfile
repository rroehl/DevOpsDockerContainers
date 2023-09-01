ARG java_version="11.0.15_10"
ARG alpine_version="3.16.0"

FROM --platform=linux/amd64 eclipse-temurin:${java_version}-jdk-alpine as jre-build

# Generate smaller java runtime without unneeded files
# for now we include the full module path to maintain compatibility
# while still saving space (approx 200mb from the full distribution)
RUN jlink \
         --add-modules ALL-MODULE-PATH \
         --strip-debug \
         --no-man-pages \
         --no-header-files \
         --compress=2 \
         --output /javaruntime 

FROM --platform=linux/amd64  alpine:${alpine_version}

#Install software
RUN apk add --no-cache \
     bash \
     coreutils \
     curl \
     git \
     git-lfs \
     gnupg \
     musl-locales \  
     musl-locales-lang \
     openssh-client \
     ttf-dejavu \
     tzdata \
     unzip \
   && git lfs install

ARG COMMIT_SHA

# Jenkins vars
ARG jenkins_version=2.375.2
    # jenkins.war checksum, download will be validated using it
ARG jenkins_sha256=e572525f7fa43b082e22896f72570297d88daec4f36ab4f25fdadca885f95492
    # Can be used to customize where jenkins.war get downloaded from
ARG jenkins_source_url=https://repo.jenkins-ci.org/public/org/jenkins-ci/main/jenkins-war/${jenkins_version}/jenkins-war-${jenkins_version}.war
#jenkins user and group vars
ARG admin_password={password}
ARG job_password={password}
#docker passord used to get to the docker market place
ARG docker_password={password}
#agentuser need to connect agent to service without plugin
ARG agentuser_password=e8cf7e78ab1e3e06d7f4d45a68e0e3c82fa4df034432e2b16c0cfd10712c04c9
ARG user=jenkins
ARG group=jenkins
ARG uid=1000
ARG gid=1000
#jenkins ports
ARG jenkins_url=[jenkins_url]  //managed by terraform
# ARG docker_password
ARG http_port=8080 //mamaged by terraform
ARG agent_port=50000 //mamaged by terraform
#jenkins folders
ARG jenkins_service_root=/apps/jenkins  //managed by terraform         
ARG jenkins_service_home=${jenkins_service_root}/jenkins_home //managed by terraform     
# $REF (defaults to `$ref  /`) contains all reference configuration we want
# to set on a fresh new installation. Use it to bundle additional plugins
# or config file with your custom jenkins Docker image.
ARG ref=${jenkins_service_home}/ref
ARG tini_path=${jenkins_service_root}/tini
ARG tmp_folder=${jenkins_service_root}/tmp_home
#jenkins agents
ARG jenkins_agent_root=/apps/jenkins
ARG jenkins_agent_home=${jenkins_agent_root}/jenkins_home
ARG jenkins_agent_workdir=${jenkins_agent_home}/agent
ARG docker_uri=tcp://robbs-macbook-pro.local:2375
ARG docker_agent_image=dockerrobb/jenkinsagent
ARG agent_home_mount=type=volume,source=agent_volume,target=${jenkins_agent_workdir}
ARG agent_dot_jenkins_mount=type=volume,source=dot_jenkins_volume,target=${jenkins_agent_home}/.jenkins
ARG jenkins_agent_label=LinuxAgentLabel
ARG jenkins_agent_name=LinuxAgentName
ARG jenkins_url=http://robbs-macbook-pro.local:8080

#java vars
ARG java_home=${jenkins_service_root}/openjdk
#tini vars
ARG  tini_version=v0.19.0
ARG TARGETARCH=amd64
#jenkins plugin manager vars.
ARG plugin_cli_version=2.12.8  

ARG PLUGIN_CLI_URL=https://github.com/jenkinsci/plugin-installation-manager-tool/releases/download/${plugin_cli_version}/jenkins-plugin-manager-${plugin_cli_version}.jar
 
ENV LANG 'en_US.UTF-8'
# configure jenkins envir vars
ENV JENKINS_ROOT ${jenkins_service_root}
ENV JENKINS_HOME ${jenkins_service_home}
ENV JENKINS_TMP ${tmp_folder}
ENV JENKINS_SLAVE_AGENT_PORT ${agent_port}
ENV JENKINS_VERSION ${jenkins_version}
ENV JENKINS_UC https://updates.jenkins.io
ENV JENKINS_UC_EXPERIMENTAL=https://updates.jenkins.io/experimental
ENV JENKINS_INCREMENTALS_REPO_MIRROR=https://repo.jenkins-ci.org/incrementals
#For the plugin manager
ENV REF ${ref}
ENV COPY_REFERENCE_FILE_LOG ${jenkins_service_home}/copy_reference_file.log
#For java
ENV JAVA_HOME=${jenkins_service_root}/openjdk
ENV PATH "${java_home}/bin:${PATH}"
#Config Jenkins system properties and CASC
ENV JENKINS_JAVA_OPTS="-Djenkins.install.runSetupWizard=false -Djenkins.security.ApiTokenProperty.adminCanGenerateNewTokens=true"
ENV CASC_JENKINS_CONFIG=${jenkins_service_home}/casc_configs/jenkins.yaml

# Create directories
RUN mkdir -p ${jenkins_service_home} \
    && mkdir -p ${tini_path} \
    && mkdir -p ${jenkins_service_root}/bin \
    && mkdir -p ${jenkins_service_root}/scripts \
    && mkdir -p ${java_home} \
    && mkdir -p ${java_home}/bin \

#get the Jenkins script on the container and configed
    && mkdir -p  ${tmp_folder} \

# Jenkins is run with user `jenkins`, uid = 1000
# If you bind mount a volume from the host or a data container,
# ensure you use the same uid
    && addgroup -g ${gid} ${group} \
    && adduser -h "${jenkins_service_home}" -u ${uid} -G ${group} -s /bin/bash -D ${user} 

#Copy gpg for tini verification
COPY tini_pub.gpg "${tini_path}/tini_pub.gpg"
#copy jenkins-config.sh jenkins.sh and plugins.txt jenkins-plugin-cli over to script folder
COPY jenkins-support jenkins.sh jenkins-plugin-cli jenkins-config.sh ${jenkins_service_root}/scripts/
# Copy the plugin txt to image
COPY plugins.txt ${tmp_folder}/
# Copy the jenkins.yaml and startup-properties.groovy to the tmp folder
COPY jenkins.yaml startup-properties.groovy ${tmp_folder}/
    #COPY jenkins.yaml ${jenkins_service_home}/casc_configs/jenkins.yaml -- done in the config script
    #COPY startup-properties.groovy ${jenkins_service_home}/init.groovy.d/startup-properties.groovy -- done in the config script
#Configure and install java
COPY --from=jre-build /javaruntime ${java_home}

# Use tini as subreaper in Docker container to adopt zombie processes
RUN curl -fsSL "https://github.com/krallin/tini/releases/download/${tini_version}/tini-static-${TARGETARCH}" -o ${tini_path}/tini \
    && curl -fsSL "https://github.com/krallin/tini/releases/download/${tini_version}/tini-static-${TARGETARCH}.asc" -o ${tini_path}/tini.asc \
    && gpg --no-tty --import "${tini_path}/tini_pub.gpg" \
    && gpg --verify ${tini_path}/tini.asc \
    && rm -rf ${tini_path}/tini.asc /root/.gnupg ${tini_path}/tini_pub.gpg \
    && chmod +x ${tini_path}/tini \

# could use ADD but this one does not check Last-Modified header neither does it allow to control checksum
# see https://github.com/docker/docker/issues/8331
    && curl -fsSL ${jenkins_source_url} -o ${jenkins_service_root}/bin/jenkins.war \
    && echo "${jenkins_sha256}  ${jenkins_service_root}/bin/jenkins.war" >/tmp/jenkins_sha256 \
    && sha256sum -c --strict /tmp/jenkins_sha256 \
    && rm -f /tmp/jenkins_sha256 \

#Download Jenkins plugin manager jar  https://github.com/jenkinsci/plugin-installation-manager-tool
    && curl -fsSL ${PLUGIN_CLI_URL} -o ${jenkins_service_root}/bin/jenkins-plugin-manager.jar \

# Configuration as Code YAML file settigs
    && sed -ir "s/password: \[admin_password\]/password: \"${admin_password}\"/" ${tmp_folder}/jenkins.yaml \
    && sed -ir "s/password: \[job_password\]/password: \"${job_password}\"/" ${tmp_folder}/jenkins.yaml \
    && sed -ir "s/password: \[docker_password\]/password: \"${docker_password}\"/" ${tmp_folder}/jenkins.yaml  \
    && sed -ir "s/password: \[agentuser_password\]/password: \"${agentuser_password}\"/" ${tmp_folder}/jenkins.yaml  \
    && sed -ir "s!url: \[jenkins_url\]!url: \"${jenkins_url}\"!" ${tmp_folder}/jenkins.yaml  \
    && sed -ir "s!uri: \[docker_uri\]!uri: \"${docker_uri}\"!" ${tmp_folder}/jenkins.yaml  \
    && sed -ir "s!image: \[docker_agent_image\]!image: \"${docker_agent_image}\"!" ${tmp_folder}/jenkins.yaml  \
    && sed -ir "s!remoteFs: \[jenkins_agent_workdir\]!remoteFs: \"${jenkins_agent_workdir}\"!" ${tmp_folder}/jenkins.yaml  \
    && sed -ir "s!\[agent_home_mount\]!${agent_home_mount}!" ${tmp_folder}/jenkins.yaml  \
    && sed -ir "s!\[agent_dot_jenkins_mount\]!${agent_dot_jenkins_mount}!" ${tmp_folder}/jenkins.yaml \
    && sed -ir "s!\[jenkins_agent_label\]!${jenkins_agent_label}!" ${tmp_folder}/jenkins.yaml \
    && sed -ir "s!\[jenkins_agent_name\]!${jenkins_agent_name}!" ${tmp_folder}/jenkins.yaml  \
    && rm -f ${tmp_folder}/jenkins.yamlr  \

# Change owner to Jenkins..Jenkins Get access to these files and execute
    && chown -R  ${uid}:${gid} ${jenkins_service_root} \
    && chmod -R u+rwx,g+rwx,o-rwx  ${jenkins_service_root}   

# for main web interface and the other will be used by attached agents:
EXPOSE ${http_port} ${agent_port}

# Change the user
USER ${user}

# Initialize the Jenkins volume and tini call jenkins.sh
#CMD ["sh","-c", "sleep 5000"]
CMD ["sh","-c", "$JENKINS_ROOT/scripts/jenkins-config.sh ; $JENKINS_ROOT/scripts/jenkins.sh"]
#CMD ["sh","-c", "$JENKINS_ROOT/scripts/jenkins-config.sh ; $JENKINS_ROOT/tini/tini -s $JENKINS_ROOT/scripts/jenkins.sh"]
#ENTRYPOINT "$JENKINS_ROOT/tini/tini" "-s" "--" "$JENKINS_ROOT/scripts/jenkins.sh"


# metadata labels
LABEL \
    org.opencontainers.image.vendor="Jenkins project" \
    org.opencontainers.image.title="Robb's Master Docker image" \
    org.opencontainers.image.description="The Jenkins Continuous Integration and Delivery server" \
    org.opencontainers.image.version="${jenkins_version}" \
    org.opencontainers.image.url="https://www.jenkins.io/" \
    org.opencontainers.image.source="https://github.com/jenkinsci/docker" \
    org.opencontainers.image.revision="${COMMIT_SHA}" \
    org.opencontainers.image.licenses="MIT"