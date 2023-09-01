 
# Migration Path
    3.16.1-02->3.30.1-01 

# DNS Name
    nexus.fhlbss.com
    
# Configure Server Server Limits

    https://coding-stream-of-consciousness.com/2018/12/21/centos7-and-rhel7-increasing-open-file-descriptors-process-limits/
    
    -- Configure Server Host Limits
        sysctl -w -q vm.max_map_count=262144 && \
        sysctl -w -q fs.file-max=65536 && \
        ulimit -n 65536 && \
        ulimit -u 4096 

# Install Nexus 3.30.1 gz
     --Download 3.30.1 to home folder
    --For for VM
        cd /apps
        mkdir ~/downloads
        cd ~/downloads
        wget https://download.sonatype.com/nexus/3/latest-unix.tar.gz
 
    -- For docker
    docker cp nexus-3.30.1-01-unix.tar.gz nexus:/apps
    --Uncompress the file and remove it
    cd /apps && tar -xvf nexus-3.30.1-01-unix.tar.gz && rm -f nexus-3.30.1-01-unix.tar.gz

# Install JDK 
    -- Ensure that either Open JDK 1.8 installed
    -- Oracle Website
    https://www.oracle.com/java/technologies/javase/javase-jdk8-downloads.html#license-lightbox

    docker cp jdk-8u291-linux-i586.tar.gz nexus:/apps

    cd /apps && tar -xvf jdk-8u291-linux-i586.tar.gz && rm -f jdk-8u291-linux-i586.tar.gz

# Create nexus soft link to folder
    cd /apps && ln -s nexus-3.30.1-01/ nexus

# Configure the nexus.vmoptions and adding the value
    cd /apps/nexus/bin && \

    -- For 8GB of RAM set -Xms2703M -Xmx2703M   -XX:MaxDirectMemorySize=2703M
    -- Set by default

    -- set the following  -XX:LogFile=/apps/sonatype-work/nexus3/log/jvm.log
    --                    -Dkaraf.data=/apps/sonatype-work/nexus3
    --                    -Dkaraf.log=/apps/sonatype-work/nexus3/log
    --                    -Djava.io.tmpdir=/apps/sonatype-work/nexus3/tmp

    cd /apps/nexus/bin && \
    sed -ir "0,/^[#]*\s*-XX:LogFile=.*/s//-XX:LogFile=\/apps\/sonatype-work\/nexus3\/log\/jvm.log/" nexus.vmoptions && \
    sed -ir "0,/^[#]*\s*-Dkaraf.data=.*/s//-Dkaraf.data=\/apps\/sonatype-work\/nexus3/" nexus.vmoptions && \
    sed -ir "0,/^[#]*\s*-Dkaraf.log=.*/s//-Dkaraf.log=\/apps\/sonatype-work\/nexus3\/log/" nexus.vmoptions && \
    sed -ir "0,/^[#]*\s*-Djava.io.tmpdir=.*/s//-Djava.io.tmpdir=\/apps\/sonatype-work\/nexus3\/tmp/" nexus.vmoptions 

# Configure the nexus script
    --  Java location open the bin/nexus script and locate the line INSTALL4J_JAVA_HOME_OVERRIDE. Remove the hash and specify the location of your JDK/JRE:
    -- uncommenty and change INSTALL4J_JAVA_HOME_OVERRIDE=/apps/jdk1.8.0_291
    cd /apps/nexus/bin && \
    sed -ir "s/^[#]*\s*INSTALL4J_JAVA_HOME_OVERRIDE=.*/INSTALL4J_JAVA_HOME_OVERRIDE=\/apps\/jdk1.8.0_291/" nexus

# Configure the security
    -- Create user and group
    Configure the security
    groupadd nexus && useradd -M -s /bin/bash -g nexus -d /apps/nexus nexus_user && \
    cd /apps && \
    chown -R nexus_user:nexus ./nexus-3.30.1-01 && \
    chmod -R u+rwx,g+rwx ./nexus-3.30.1-01  && \
    chmod -R o-rwx ./nexus-3.30.1-01

# Configure security on the nexus data file
    cd /apps && \
    chown -R nexus_user:nexus ./sonatype-work && \
    chmod -R u+rwx,g+rwx ./sonatype-work  && \
    chmod -R o-rwx ./sonatype-work

# Configure security on the JAVA folder
    cd /apps && \
    chown -R nexus_user:nexus ./jdk1.8.0_291 && \
    chmod -R u+rwx,g+rwx ./jdk1.8.0_291  && \
    chmod -R o-rwx ./jdk1.8.0_291
# Configure the systemd file
    
    -- /usr/lib/systemd/system/
    #container copy the
    docker cp nexus.service nexus:/usr/lib/systemd/system/nexus.service
    
    -- image configure
    cp  nexus.service /usr/lib/systemd/system/nexus.service

    -- Configure systemd file
    chmod 664 /usr/lib/systemd/system/nexus.service
    systemctl enable nexus.service    
    systemctl daemon-reload

    -- Once configured to edit do the following
    systemctl edit sonar

# Docker commands
    Create image : docker build --rm -t "nexus:3.30.1-01" --file Dockerfile3.30.1 .
    Create container and start it: docker run -i -d -t -h nexus3.30.1 --name nexus3.30.1 --cap-add=NET_ADMIN --privileged=true -p 8081:8081  nexus:3.30.1-01 /usr/sbin/init
    SSH into container: docker exec -it nexus3.30.1 /bin/bash 
    Start Container: docker container start  nexus3.30.1
    Stop Container: docker container stop  nexus3.30.1
    Delete Container: docker container rm  nexus3.30.1
    Delete image: docker image rm nexus:3.30.1-01 


