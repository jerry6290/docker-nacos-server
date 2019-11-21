# docker-nacos-server

官方的docker镜像过大，导入完整的centos7.4和完整的openjdk1.8，另外做使用过程中发现v1.1.4版本build有问题，导致升级失败。

改成用 adoptopenjdk/openjdk8:x86_64-alpine-jre8u232-b09作为基础镜像，基础镜像只有45M大小
