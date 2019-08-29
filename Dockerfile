FROM scratch

ADD centos-7-x86_64-docker.tar.xz /
ADD mm-wiki-linux-amd64.tar.gz /usr/local/

COPY entrypoint.sh /usr/local/mm-wiki
COPY tini_0.18.0-amd64.rpm /tmp

RUN set -x \
        && /bin/cp /usr/share/zoneinfo/Asia/Shanghai /etc/localtime \
        && rpm -ivh /tmp/tini_0.18.0-amd64.rpm 

ENTRYPOINT ["/usr/bin/tini", "--"]
CMD ["/usr/local/mm-wiki/entrypoint.sh"]


