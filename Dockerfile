FROM ubuntu:jammy
LABEL MAINTAINER="Kevin Jiang"

ENV DEBIAN_FRONTEND noninteractive

# Install packages needed for SSH and interactive OS
RUN apt-get update && \
    yes | unminimize && \
    apt-get -y install \
        openjdk-8-jdk \
        openssh-server \
        passwd \
        sudo \
        man-db \
        curl \
        wget \
        postgresql \
        net-tools \
        redis \
        vim-tiny && \
    apt-get -qq clean && \
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

RUN wget https://dlcdn.apache.org/maven/maven-3/3.6.3/binaries/apache-maven-3.6.3-bin.tar.gz -P /tmp && \
    sudo tar xf /tmp/apache-maven-*.tar.gz -C /opt

# Enable systemd (from Matthew Warman's mcwarman/vagrant-provider)
RUN (cd /lib/systemd/system/sysinit.target.wants/; for i in *; do [ $i == systemd-tmpfiles-setup.service ] || rm -f $i; done); \
    rm -f /lib/systemd/system/multi-user.target.wants/*; \
    rm -f /etc/systemd/system/*.wants/*; \
    rm -f /lib/systemd/system/local-fs.target.wants/*; \
    rm -f /lib/systemd/system/sockets.target.wants/*udev*; \
    rm -f /lib/systemd/system/sockets.target.wants/*initctl*; \
    rm -f /lib/systemd/system/basic.target.wants/*; \
    rm -f /lib/systemd/system/anaconda.target.wants/*;

# Enable ssh for vagrant
RUN systemctl enable ssh.service; 
EXPOSE 22

# Create the vagrant user
RUN useradd -m -G sudo -s /bin/bash vagrant && \
    echo "vagrant:vagrant" | chpasswd && \
    echo 'vagrant ALL=(ALL) NOPASSWD: ALL' > /etc/sudoers.d/vagrant && \
    chmod 440 /etc/sudoers.d/vagrant

# Establish ssh keys for vagrant
RUN mkdir -p /home/vagrant/.ssh; \
    chmod 700 /home/vagrant/.ssh
ADD https://raw.githubusercontent.com/hashicorp/vagrant/master/keys/vagrant.pub /home/vagrant/.ssh/authorized_keys
RUN chmod 600 /home/vagrant/.ssh/authorized_keys; \
    chown -R vagrant:vagrant /home/vagrant/.ssh

RUN sudo echo 'export M2_HOME=/opt/apache-maven-3.6.3' >> ~/.bashrc && \
    sudo echo 'export PATH=${M2_HOME}/bin:${PATH}' >> ~/.bashrc && \
    sudo echo 'export JAVA_HOME=/usr/lib/jvm/java-8-openjdk-arm64' >> ~/.bashrc

RUN sudo echo "host    all             all             0.0.0.0/0               trust" >> /etc/postgresql/14/main/pg_hba.conf && \
    sudo echo "listen_addresses = '*'" >> /etc/postgresql/14/main/postgresql.conf && \
    sudo service postgresql restart
    # sudo -i -u postgres

# Run the init daemon
VOLUME [ "/sys/fs/cgroup" ]
CMD ["/usr/sbin/init"]