FROM ubuntu:14.04
MAINTAINER kischang "734615869@qq.com"

#覆盖为aliyu
ADD ./sources.list_14-04 /etc/apt/sources.list

#更新源
RUN apt-get update

#安装工具、编译、编译依赖
RUN apt-get install -y wget unzip
RUN apt-get install -y gcc make
RUN apt-get install -y libpcre3 libpcre3-dev zlib1g-dev

#1. 安装libfastcommon
WORKDIR /root
RUN wget -O libfastcommon-master.zip https://github.com/happyfish100/libfastcommon/archive/master.zip
RUN unzip libfastcommon-master.zip
WORKDIR /root/libfastcommon-master
RUN /bin/bash make.sh
RUN /bin/bash make.sh install

#2. 安装fastDFS 5.08
WORKDIR /root
RUN wget -O /root/FastDFS-V5.08.tar.gz https://github.com/happyfish100/fastdfs/archive/V5.08.tar.gz
RUN tar -xzvf /root/FastDFS-V5.08.tar.gz
WORKDIR /root/fastdfs-5.08
RUN /bin/bash make.sh
RUN /bin/bash make.sh install

#3.1 下载 fastdfs-nginx-module
WORKDIR /root
RUN wget -O /root/fastdfs-nginx-module.zip https://github.com/happyfish100/fastdfs-nginx-module/archive/master.zip
RUN unzip /root/fastdfs-nginx-module.zip -d /root

#3.2 配置依赖问题
WORKDIR /root
RUN rm -rf /usr/local/lib/libfastcommon.so
RUN rm -rf /usr/lib/libfastcommon.so
RUN rm -rf /usr/local/lib/libfdfsclient.so
RUN rm -rf /usr/lib/libfdfsclient.so
RUN ln -s /usr/lib64/libfastcommon.so /usr/local/lib/libfastcommon.so
RUN ln -s /usr/lib64/libfastcommon.so /usr/lib/libfastcommon.so
RUN ln -s /usr/lib64/libfdfsclient.so /usr/local/lib/libfdfsclient.so
RUN ln -s /usr/lib64/libfdfsclient.so /usr/lib/libfdfsclient.so

#4. 编译安装Nginx 1.2.0
WORKDIR /root
RUN wget http://nginx.org/download/nginx-1.2.0.tar.gz
RUN tar -xzvf ./nginx-1.2.0.tar.gz
WORKDIR /root/nginx-1.2.0
RUN ./configure --prefix=/usr/local/nginx --add-module=../fastdfs-nginx-module-master/src
RUN cd /root/nginx-1.2.0
RUN make && make install

#5. 复制配置文件和脚本
RUN mkdir -p /fastdfs/data
RUN mkdir -p /fastdfs/logs
RUN rm -rf /etc/fdfs/*
RUN mkdir -p /etc/fdfs
ADD ./conf/* /etc/fdfs/
ADD ./start.sh /start.sh

#7. 覆盖nginx 配置
ADD ./nginx.conf /usr/local/nginx/conf/nginx.conf

#6. 启动
CMD /bin/bash /start.sh

ENTRYPOINT /bin/bash