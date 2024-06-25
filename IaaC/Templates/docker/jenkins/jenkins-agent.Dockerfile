FROM ubuntu:22.04

# Java and open-ssh installation and set openjdk-8-jdk is default java tools
RUN apt-get update

RUN apt-get install -y openjdk-8-jdk openssh-server && \
    update-alternatives --set java /usr/lib/jvm/java-8-openjdk-amd64/jre/bin/java

# Set environnmental variables
ENV JAVA_HOME=/usr/lib/jvm/java-8-openjdk-amd64
ENV PATH=${JAVA_HOME}/bin:${PATH}

# Add a non-root user and group with UID and GID 1000 and a home directory
RUN groupadd -g 1000 tuxtechlab && \
    useradd -u 1000 -g tux -s /bin/bash -m -d /home/tux tux && usermod -aG sudo tux

# Set a password for the "tux" user ( Change "your_password" to your desired password)
RUN echo ${JENKINS_AGENT_PASSWORD} | chpasswd

# Start sshd service when container start
RUN service ssh start

# Start the SSH server on container startup
EXPOSE 22

CMD ["/usr/bin/sshd", "-D"]