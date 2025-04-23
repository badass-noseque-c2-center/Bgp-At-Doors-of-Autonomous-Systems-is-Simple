FROM docker:dind

ARG USER=mrodrigu

RUN apk add openssh-server

RUN adduser -S -s /bin/sh $USER

RUN ssh-keygen -A

RUN echo -e "PasswordAuthentication no" >> /etc/ssh/sshd_config && \
    echo -e "\n" | passwd $USER

COPY ./authorized_keys /home/$USER/.ssh/authorized_keys

ENTRYPOINT ["/usr/sbin/sshd", "-D"]
