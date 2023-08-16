FROM alpine:3.18

RUN apk update
RUN apk add \
    git \
    make \
    cmake
RUN apk add gcc-arm-none-eabi=12.2.0-r8
RUN apk add g++-arm-none-eabi=12.2.0-r1

ARG USERNAME=armbuilder
RUN adduser $USERNAME;echo 'armbuilder:armpass' | chpasswd

USER $USERNAME
