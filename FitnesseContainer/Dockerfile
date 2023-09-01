FROM centos:centos7.9.2009
#Set ENV vars
env JAVA_HOME=/usr/lib/jvm/jre-1.8.0-openjdk
env FITNESSE_HOME=/apps/fitnesse
env FITNESSE_PORT=80
env RUN_AS_USER=fitnesse_user
env PATH=$JAVA_HOME/bin:$PATH
env FITNESSE_LOG_PATH=/apps/fitnesse/logs/
env FITNESSE_STARTUP_LOG=fitnesse.startup.log

#install open JDK 
RUN yum install -y java-1.8.0-openjdk 
#Create folders
RUN mkdir  /apps \
&& 	mkdir  /apps/fitnesse \
&&  mkdir /apps/fitnesse/logs 
#&&  mkdir /apps/fitnesse/scripts/
# Create a fitness user and group
RUN groupadd fitnesse \
&&  useradd -M -s /bin/bash -G fitnesse -d /apps/fitnesse fitnesse_user
# Copy files to container
COPY fitnesse-standalone.jar /apps/fitnesse 
#COPY fitnesse.sh /apps/fitnesse/scripts
# Set folder permissions	
RUN chown -R root:fitnesse /apps/fitnesse \
&&  chmod -R u+rwx,g+rwx /apps/fitnesse \
&&	chmod -R o-rwx  /apps/fitnesse

#CMD echo "CMD ENV $OPERATION"

#ENTRYPOINT ["/bin/bash"]
#CMD ["/bin/bash","-c","/apps/fitnesse/scripts/fitnesse.sh ${OPERATION}"]
#CMD ["su","-s","/bin/bash","-c", "nohup /usr/lib/jvm/jre-1.8.0-openjdk/bin/java -jar /apps/fitnesse/fitnesse-standalone.jar -d /apps/fitnesse -l /apps/fitnesse/logs/ -p 80 >> /apps/fitnesse/logs/fitnesse.startup.log","fitnesse_user"]

CMD ["su", "fitnesse_user" , "-s","/bin/bash","-c", "nohup ${JAVA_HOME}/bin/java -jar ${FITNESSE_HOME}/fitnesse-standalone.jar -d ${FITNESSE_HOME} -l ${FITNESSE_LOG_PATH} -p ${FITNESSE_PORT} >> ${FITNESSE_LOG_PATH}${FITNESSE_STARTUP_LOG}"]

#su -s /bin/bash -c 'nohup $JAVA_HOME/bin/java -jar $FITNESSE_HOME/fitnesse-standalone.jar -d $FITNESSE_HOME -l $FITNESSE_LOG_PATH -p $FITNESSE_PORT >> $FITNESSE_LOG_PATH$FITNESSE_STARTUP_LOG  ' $RUN_AS_USER




EXPOSE 80


#form1
#ENV param value
# form2
#ENV param1=value1,param2=value2s
#CMD ["echo", "${MY_HOME}"]