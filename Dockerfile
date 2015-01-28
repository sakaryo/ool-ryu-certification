FROM debian

MAINTAINER Hiroshi Sakoda <hiroshi.sakoda@oolorg.mygbiz.com>

RUN apt-get update && apt-get -y upgrade \
&& apt-get install -qy --no-install-recommends python-setuptools python-pip python-eventlet python-lxml msgpack-python python-netaddr python-paramiko python-routes python-six python-webob openjdk-7-jre-headless git sudo && pip install oslo.config

RUN useradd -d /var/lib/jenkins -m jenkins && echo "jenkins\tALL=(ALL:ALL) NOPASSWD:ALL" >> /etc/sudoers

ADD http://mirrors.jenkins-ci.org/war-stable/latest/jenkins.war /usr/share/jenkins/
ADD https://updates.jenkins-ci.org/latest/git.hpi /var/lib/jenkins/plugins/
ADD https://updates.jenkins-ci.org/latest/git-client.hpi /var/lib/jenkins/plugins/
ADD https://updates.jenkins-ci.org/latest/scm-api.hpi /var/lib/jenkins/plugins/
ADD https://updates.jenkins-ci.org/latest/multiple-scms.hpi /var/lib/jenkins/plugins/

RUN mkdir -p /usr/local/share/jenkins && mkdir -p /var/log/jenkins && chown jenkins:jenkins /var/log/jenkins \
&& echo "#!/bin/bash\n\nNAME=jenkins\nJENKINS_WAR=/usr/share/jenkins/jenkins.war\nJENKINS_LOG=/var/log/jenkins/\$NAME.log\nJENKINS_HOME=/var/lib/jenkins\n\nexec /bin/su - \$NAME -c \"export JENKINS_HOME=\$JENKINS_HOME && java -jar \$JENKINS_WAR --logfile=\$JENKINS_LOG\"" > /usr/local/share/jenkins/jenkins.sh \
&& chmod +x /usr/local/share/jenkins/jenkins.sh && chmod +r /usr/share/jenkins/jenkins.war && chmod +r -R /var/lib/jenkins/plugins \
&& chown -R jenkins:jenkins /var/lib/jenkins/plugins

RUN git clone -b docker https://github.com/oolorg/ool-ryu-certification.git && cp -r ool-ryu-certification/jobs /var/lib/jenkins/ && rm -rf ool-ryu-certification \
&& chown -R jenkins:jenkins /var/lib/jenkins/jobs

RUN echo Asia/Tokyo > /etc/timezone && cp -p /usr/share/zoneinfo/Asia/Tokyo /etc/localtime

ENTRYPOINT ["/usr/local/share/jenkins/jenkins.sh"]
