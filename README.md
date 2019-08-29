

#### 一、mm-wiki简介
MM-Wiki 是一个轻量级的企业知识分享与团队协同软件，可用于快速构建企业 Wiki 和团队知识分享平台。部署方便，使用简单，帮助团队构建一个信息共享、文档管理的协作环境。

**特点**
- 部署方便，基于 golang 编写，只需要下载对于平台下二进制文件执行即可。
- 快速安装程序, 提供方便的安装界面程序，无需任何手动操作。
- 独立的空间，空间是一组文档的集合，一般为公司部门或者团队，空间下的文档相互独立。空间可根据需求设置空间访问级别。
- 完善的系统权限管理，系统可以自定义角色，并为不同角色授予不同的权限。
- 集成统一登录，本系统支持通过外部系统认证用户, 比如与公司的 LDAP 登录融合。具体请看登录认证功能。
- 邮件通知功能，当开启邮件通知，文档更改会通知所有关注该文档的用户。
- 文档具有分享和下载功能，目前只支持下载 MarkDown 源文件。

**项目地址：https://github.com/phachon/MM-Wiki**


#### 二、mm-wiki容器化，Dockerfile文件内容如下
```shell
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

```


#### 三、entrypoint启动脚本如下
```bash
#!/bin/bash
#


# Define the data storage directory, default is "/data".
DATA=${DATA:=/data}

WORK="/usr/local/mm-wiki"
OCFG="$WORK/conf"
CONF="$DATA/conf"

if [ ! -L "$OCFG" ]; then
    if [ ! -d $CONF ]; then
        mkdir -p $CONF
        mv $OCFG/* $CONF
    fi
    rm -fr $OCFG
    ln -s $CONF $OCFG
fi

if [ ! -f "$OCFG/mm-wiki.conf" ]; then
    exec $WORK/install/install -port 8080
else
    exec $WORK/mm-wiki -conf $OCFG/mm-wiki.conf
fi

```


#### 四、docker-compose文件内容如下
```yaml
version: "3"
services:
    mm-wiki:
        build:
            context: .
            dockerfile: Dockerfile
        image: mm-wiki:20190718
        environment:
            DATA: /data
        ports:
          - 80:8080
        volumes:
          - /data/mm_wiki:/data

```


#### 五、容器管理
1.构建mm-wiki镜像
```shell
[root@hub mm-wiki]# docker-compose build
Building mm-wiki
Step 1/8 : FROM scratch
 ---> 
Step 2/8 : ADD centos-7-x86_64-docker.tar.xz /
 ---> 4c584d42e656
Step 3/8 : ADD mm-wiki-linux-amd64.tar.gz /usr/local/
 ---> f73f6bd0f6b7
.....

[root@hub mm-wiki]# docker images
REPOSITORY                      TAG                        IMAGE ID            CREATED             SIZE
mm-wiki                         20190718                   3a03e908ac13        3 hours ago         278MB
```

2.创建mm_wiki库和mm_wiki用户
```sql
MariaDB [(none)]> CREATE DATABASE mm_wiki DEFAULT CHARACTER SET utf8 COLLATE utf8_general_ci;
MariaDB [(none)]> CREATE USER 'mm_wiki'@'%' IDENTIFIED BY 'xxxx';
MariaDB [(none)]> GRANT ALL ON mm_wiki.* TO 'mm_wiki'@'%';
```

3.启动mm-wiki服务(注意: 第一次启动会进行数据初始化)
```shell
[root@hub mm-wiki]# docker-compose up -d
Creating network "mm-wiki-docker_default" with the default driver
Creating mm-wiki-docker_mm-wiki_1 ... done
```

4.停止服务
```shell
[root@hub mm-wiki]# docker-compose down
Stopping mm-wiki-docker_mm-wiki_1 ... done
Removing mm-wiki-docker_mm-wiki_1 ... done
Removing network mm-wiki-docker_default
```


#### 六、初始化

1.访问容器地址初始化即可（注意：文件保存目录要和环境变量DATA一致）

2.初始化成功后重启下容器即可登录。



