 
# Migration Path
    7.9.1 <-8.6.1.40680 LTS <- 6.7.5.38563 (Old version)
    
# Configure Server Server Limits

    https://coding-stream-of-consciousness.com/2018/12/21/centos7-and-rhel7-increasing-open-file-descriptors-process-limits/
    
    ulimit -a 

# Install 8.6.1.40680

    mkdir /apps 

    # install unzip
    yum install -Y unzip   

# Install SoanrQube zip
  
    --Install for VM
    --Download 8.6.1.40680 LTS to home folder
        mkdir ~/downloads
        cd ~/downloads
        wget https://binaries.sonarsource.com/Distribution/sonarqube/sonarqube-8.6.1.40680.zip
 
    -- For docker
    docker cp sonarqube-8.6.1.40680.zip slave:/apps

    --Unzip the file and remove it
    cd /apps && unzip sonarqube-8.6.1.40680.zip && rm -f sonarqube-8.6.1.40680.zip

# Install JDK 
    -- Ensure that either Open JDK 11 installed
    -- Oracle Websit
    https://www.oracle.com/java/technologies/javase-jdk11-downloads.html

    docker cp jdk-11.0.10_linux-x64_bin.tar.gz qaslave:/apps

    cd /apps/sonarqube-8.6.1.40680/ && tar -xvf ../jdk-11.0.10_linux-x64_bin.tar.gz && rm -f ../jdk-11.0.10_linux-x64_bin.tar.gz
 
 # Install JDBC driver https://www.oracle.com/database/technologies/appdev/jdbc-ucp-19c-downloads.html
    -- copy the JDBC driver into $SONARQUBE-HOME/extensions/jdbc-driver/oracle.
    -- For docker
    docker cp ojdbc8.jar slave:/apps/sonarqube-8.6.1.40680/extensions/jdbc-driver/oracle
    -- or this
    mv /apps/ojdbc8.jar   /apps/sonarqube-8.6.1.40680/extensions/jdbc-driver/oracle

# Configure the sonar.properties by uncommenting and adding the value

     -- Uncomment the user credentials and the Oracle related settings:
    #sonar.jdbc.username=  and  sonar.jdbc.password=
    cd /apps/sonarqube-8.6.1.40680/conf && \
    sed -ir "s/^[#]*\s*sonar.jdbc.username=.*/sonar.jdbc.username=username/" sonar.properties && \
    sed -ir "s/^[#]*\s*sonar.jdbc.password=.*/sonar.jdbc.password=password/" sonar.properties

     -- JDBC connect string Replace the 1st occurance
    -- jdbc:oracle:thin:@//<host>:<port>/<service_name>   Example: jdbc:oracle:thin:@//192.168.2.1:1521/XE
    --                      host:port:sid                 Examplejdbc:oracle:thin:@prodHost:1521:ORCL"
    #sonar.jdbc.url=jdbc:oracle:thin:@localhost:1521/XE
     cd /apps/sonarqube-8.6.1.40680/conf && \
    sed -ir "0,/^[#]*\s*sonar.jdbc.url=.*/s//sonar.jdbc.url=jdbc:oracle:thin:awdrdborcl19001.cfuqq3dxlzcz.us-west-2.rds.amazonaws.com@:1521:ORCL/" sonar.properties

    --The following settings allow you to run the server on page http://localhost:9000/sonar
    # sonar.web.port=9000
    cd /apps/sonarqube-8.6.1.40680/conf && \
    sed -ir "s/^[#]*\s*sonar.web.port=.*/sonar.web.port=9000/" sonar.properties

    --- AD LDAP Configuration
    # sonar.security.realm=LDAP 
    # ldap.url=ldap://awdw-ifaddc-001.fhlbsf-i.com:389 
    # ldap.bindDn=svcsys_aws-ad@fhlbsf-i.com
    # ldap.bindPassword=PASSWORD
    # ldap.user.baseDn=OU=FHLB-Accounts,DC=fhlbsf-i,DC=com
    # ldap.user.request=(&(objectClass=user)(sAMAccountName={login}))
    ##(&(objectCategory=Person)(sAMAccountName=*))
    # ldap.user.realNameAttribute=cn
    # ldap.user.emailAttribute=mail
    # ldap.group.baseDn=OU=Groups,OU=FHLB-Accounts,DC=fhlbsf-i,DC=com
    # ldap.group.idAttribute=sAMAccountName

    cd /apps/sonarqube-8.6.1.40680/conf && \
    sed -ir "s/^[#]*\s*sonar.security.realm=.*/sonar.security.realm=LDAP/" sonar.properties && \
    sed -ir "s/^[#]*\s*ldap.url=.*/ldap.url=ldap:\/\/awdw-ifaddc-001.fhlbsf-i.com:389/" sonar.properties && \
    sed -ir "s/^[#]*\s*ldap.bindDn=.*/ldap.bindDn=svcsys_aws-ad@fhlbsf-i.com/" sonar.properties && \
    sed -ir "s/^[#]*\s*ldap.bindPassword=.*/ldap.bindPassword=PASSSSSSSSWOOOORD /" sonar.properties && \
    sed -ir "s/^[#]*\s*ldap.user.baseDn=.*/ldap.user.baseDn=OU\=FHLB-Accounts,DC\=fhlbsf-i,DC\=com/" sonar.properties && \
    sed -ir "s/^[#]*\s*ldap.user.request=.*/ldap.user.request=(\&(objectClass\=user)(sAMAccountName\={login}))/" sonar.properties && \
    sed -ir "s/^[#]*\s*ldap.user.realNameAttribute=.*/ldap.user.realNameAttribute=cn/" sonar.properties && \
    sed -ir "s/^[#]*\s*ldap.user.emailAttribute=.*/ldap.user.emailAttribute=mail/" sonar.properties && \
    sed -ir "s/^[#]*\s*ldap.group.baseDn=.*/ldap.group.baseDn=OU\=Groups,OU\=FHLB-Accounts,DC\=fhlbsf-i,DC\=com/" sonar.properties && \
    sed -ir "s/^[#]*\s*ldap.group.idAttribute=.*/ldap.group.idAttribute=sAMAccountName/" sonar.properties && \
    sed -ir "s/^[#]*\s*ldap.group.request=.*/ldap.group.request=(\&(objectClass=group)(member={dn}))/" sonar.properties 

    # AD LDAP Configuration
        sonar.security.realm=LDAP
        ldap.url=ldap://awdw-ifaddc-001.fhlbsf-i.com:389
        ldap.bindDn=svcsys_aws-ad@fhlbsf-i.com
        ldap.bindPassword=PASSWORD
        ldap.user.baseDn=OU=FHLB-Accounts,DC=fhlbsf-i,DC=com
        ldap.user.request=(&(objectClass=user)(sAMAccountName={login}))
        ##(&(objectCategory=Person)(sAMAccountName=*))
        ldap.user.realNameAttribute=cn
        ldap.user.emailAttribute=mail
        ldap.group.baseDn=OU=Groups,OU=FHLB-Accounts,DC=fhlbsf-i,DC=com
        ldap.group.idAttribute=sAMAccountName
        ldap.group.request=(&(objectClass=group)(member={dn}))

       
# Configure the wrapper.conf
    --Modify wrapper.conf with the correct java wrapper.java.command=/apps/jdk-11.0.10/bin/java does not remove the comment character
    cd /apps/sonarqube-8.6.1.40680/conf && \
    sed -ir "s/wrapper.java.command=.*/wrapper.java.command=\/apps\/sonarqube-8.6.1.40680\/jdk-11.0.10\/bin\/java/" wrapper.conf

# Configure the sonar.sh Uncomment and modify sonar.sh with the run as user  RUN_AS_USER=sonarqube_usesr , Only on the 1st occurance 
    cd /apps/sonarqube-8.6.1.40680/bin/linux-x86-64 && \
    sed -ir "0,/^[#]*\s*RUN_AS_USER=.*/s//RUN_AS_USER=sonarqube_user/" sonar.sh
    
# For the container configure the run.sh  variables processname=  fulllogpath=   fullstartscriptpath=
    cd /apps/sonarqube-8.6.1.40680/bin/linux-x86-64  && \
    sed -ir "s/^[#]*\s*processname=.*/processname=sonarqube/" run.sh && \
    sed -ir "s/^[#]*\s*fulllogpath=.*/fulllogpath=\/apps\/sonarqube-8.6.1.40680\/logs\/container.log/" run.sh && \
    sed -ir "s/^[#]*\s*fullstartscriptpath=.*/fullstartscriptpath=\/apps\/sonarqube-8.6.1.40680\/bin\/linux-x86-64\/sonar.sh/" run.sh 

# Configure the security
 
    -- Create user and group
    groupadd sonarqube && useradd -M -s /bin/bash -g sonarqube -d /apps/sonarqube-8.6.1.40680 sonarqube_user
 
    --Add your current login user to sonarqube group Optional
    usermod -a -G sonarqube {your user account}
    -- logout... log back in to get group settings

    -- set user and group owners
    -- Set file permissions
    -- Remove all other permissions
    cd /apps && \
    chown -R root:sonarqube ./sonarqube-8.6.1.40680 && \
    chmod  -R u+rwx,g+rwx ./sonarqube-8.6.1.40680  && \
    chmod -R o-rwx ./sonarqube-8.6.1.40680

# Configure the systemd file
    

     /usr/lib/systemd/system/
    docker cp fitnesse.service slave:/usr/lib/systemd/system/sonar.service
    or
    cp  fitnesse.service /usr/lib/systemd/system/sonar.service

    chmod 664 /usr/lib/systemd/system/sonar.service
    systemctl enable sonar.service    
    systemctl daemon-reload

    systemctl edit sonar


#  Docker commands
    -- Create container that supports both systemd fitnesse and sonarqube
    docker run -d -t -h {name} -p 8080:80 --name {name} --cap-add=NET_ADMIN --privileged=true centos:centos7.9.2009 /usr/sbin/init
    docker run -it -d -t -h qaslave --name qaslave -p 8080:8080 -p 8081:9000 --cap-add=NET_ADMIN --privileged=true slave /usr/sbin/init

    --Docker inspect network bridge
    docker network inspect bridge

    Docker File Configuration
    https://stackoverflow.com/questions/54425144/how-to-create-a-properties-file-via-dockerfile-with-dynamic-values-passed-in-doc

    AWS Notes
    -- API Gateway links
    https://aws.amazon.com/blogs/compute/access-private-applications-on-aws-fargate-using-amazon-api-gateway-privatelink/

    -- Creating a private API in Amazon API Gateway
    https://docs.aws.amazon.com/apigateway/latest/developerguide/apigateway-private-apis.html


# Configure sonar scanner
    cd /apps
    Windows : https://binaries.sonarsource.com/Distribution/sonar-scanner-cli/sonar-scanner-cli-4.6.1.2450-windows.zip
    wget https://binaries.sonarsource.com/Distribution/sonar-scanner-cli/sonar-scanner-cli-4.6.1.2450-linux.zip
    unzip sonar-scanner-cli-4.6.1.2450-linux.zip
    chown -R root:jenkins ./sonar-scanner-4.6.1.2450-linux/
    chmod  -R u+rwx,g+rwx ./sonar-scanner-4.6.1.2450-linux/
    chmod -R o-rwx ./sonar-scanner-4.6.1.2450-linux/

