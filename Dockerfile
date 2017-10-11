# Build this image:  docker build -t mpi .
#

FROM ubuntu:16.04
# FROM phusion/baseimage

MAINTAINER Ole Weidner <ole.weidner@ed.ac.uk>

ENV USER mpirun

ENV DEBIAN_FRONTEND=noninteractive \
    HOME=/home/${USER} 


RUN apt-get update -y && \
    apt-get install -y --no-install-recommends sudo apt-utils && \
    apt-get install -y --no-install-recommends openssh-server \
        python-dev python-numpy python-pip python-virtualenv python-scipy vim make \
        gcc gfortran libopenmpi-dev openmpi-bin openmpi-common openmpi-doc binutils && \
    apt-get clean && apt-get purge && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

RUN mkdir /var/run/sshd
RUN echo 'root:${USER}' | chpasswd
RUN sed -i 's/PermitRootLogin without-password/PermitRootLogin yes/' /etc/ssh/sshd_config

# SSH login fix. Otherwise user is kicked off after login
RUN sed 's@session\s*required\s*pam_loginuid.so@session optional pam_loginuid.so@g' -i /etc/pam.d/sshd

ENV NOTVISIBLE "in users profile"
RUN echo "export VISIBLE=now" >> /etc/profile

# ------------------------------------------------------------
# Add an 'mpirun' user
# ------------------------------------------------------------

RUN adduser --disabled-password --gecos "" ${USER} && \
    echo "${USER} ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers

# ------------------------------------------------------------
# Set-Up SSH
# ------------------------------------------------------------
RUN ssh-keygen -q -t rsa -N '' -f /id_rsa
COPY ./src/ssh/* /root/.ssh/
RUN chmod 400 /root/.ssh/id_rsa

RUN mkdir -p ~/.ssh && touch ~/.ssh/authorized_keys
RUN cat /root/.ssh/id_rsa.pub >> /root/.ssh/authorized_keys
RUN echo "    IdentityFile ~/.ssh/id_rsa" >> /etc/ssh/ssh_config

RUN sed -i 's/PermitRootLogin without-password/PermitRootLogin yes/g' /etc/ssh/sshd_config
RUN sed 's@session\s*required\s*pam_loginuid.so@session optional pam_loginuid.so@g' -i /etc/pam.d/sshd
RUN sed -i 's/#   StrictHostKeyChecking ask/StrictHostKeyChecking no/g' /etc/ssh/ssh_config

ENV NOTVISIBLE "in users profile"
RUN echo "export VISIBLE=now" >> /etc/profile
RUN echo "export PATH=$PATH" >> /etc/profile
RUN echo "ldconfig" >> /etc/profile

EXPOSE 22

RUN pip install --upgrade pip \
    && pip install -U setuptools \
    && pip install mpi4py

# ------------------------------------------------------------
# Configure OpenMPI
# ------------------------------------------------------------

RUN rm -fr ${HOME}/.openmpi && mkdir -p ${HOME}/.openmpi
ADD default-mca-params.conf ${HOME}/.openmpi/mca-params.conf
RUN chown -R ${USER}:${USER} ${HOME}/.openmpi

# ------------------------------------------------------------
# Copy MPI4PY example scripts
# ------------------------------------------------------------

ENV TRIGGER 1

ADD mpi4py_benchmarks ${HOME}/mpi4py_benchmarks
RUN chown -R ${USER}:${USER} ${HOME}/mpi4py_benchmarks

EXPOSE 22
# CMD ["/usr/sbin/sshd"]
CMD ["/usr/sbin/sshd", "-D"]
# CMD ["/bin/bash"]
