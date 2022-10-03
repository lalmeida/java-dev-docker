#
# This is a big fat local developer environment with all the tools I can possibly need for java development...
#
FROM ubuntu:latest

# Running as root...

# Re-enabling man pages
RUN yes | unminimize

# 
# Installing Docker in the container ("Docker in Docker")
#  (following  the instructions in:
#		https://devopscube.com/run-docker-in-docker/ and 
#   	https://docs.docker.com/engine/install/ubuntu/ )
# 
RUN addgroup docker --gid 1001 # where '1001' is the docker gid of the host machine (replace if necessary)
RUN apt-get update && apt-get install -y ca-certificates curl gnupg lsb-release
RUN mkdir -p /etc/apt/keyrings
RUN curl -fsSL https://download.docker.com/linux/ubuntu/gpg | gpg --dearmor -o /etc/apt/keyrings/docker.gpg
RUN echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu \
  $(lsb_release -cs) stable" | tee /etc/apt/sources.list.d/docker.list > /dev/null
RUN apt-get update && apt-get install -y docker-ce docker-ce-cli containerd.io docker-compose-plugin

# Installing everything else
RUN apt-get update && apt-get install -y maven git openjdk-11-jdk sudo vim man-db
# This script assumes you have placed your maven settings.xml in maven/settings.xml!
COPY maven/settings.xml /etc/maven

# Creating an ordinary user
RUN adduser lalmeida
# Adding the ordinary user to the host machine docker group (gid=1001)
#  This is so that the maven docker plugin in the container can communicate with the docker daemon in the host machine 
#  The comunication is done via the unix socket /var/run/docker.sock and - in my manchine :) - this file belongs to gid 1001
RUN usermod -a -G docker lalmeida

EXPOSE 8080


# At the end, set the user and run the commands that shouldn´t be run as root. 
#USER lalmeida

VOLUME /mnt/dev
WORKDIR /mnt/dev

#RUN ... installation of local lalmeida apps ? ... 

ARG GIT_USER_NAME
ARG GIT_USER_EMAIL
RUN git config --global user.name $GIT_USER_NAME && git config --global user.email $GIT_USER_EMAIL
RUN git config --global init.defaultBranch master

