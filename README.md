# jianmu-runner-git-clone

#### 介绍

用于向指定的git引擎clone项目

####  输入参数

```
netrc_username: git平台的账号
netrc_password: git平台的密码
ssh_key: ssh私钥
remote_url: git地址
netrc_machine: git引擎
ref: 标签或分支
```

#### 输出参数

```
 git_path: git clone目录
 git_branch: 如果选择git分支，返回分支名
 git_tag: 如果选择某个标签，返回标签
```

#### 构建docker镜像

```
# 创建docker镜像
docker build -t jianmudev/jianmu-runner-git-clone:${version} -f dockerfile/Dockerfile .

# 上传docker镜像
docker push jianmudev/jianmu-runner-git-clone:${version}
```

#### 用法

```
# use username password
docker run --rm \
  -e JIANMU_NETRC_USERNAME=xxx \
  -e JIANMU_NETRC_PASSWORD=xxx \
  -e JIANMU_REMOTE_URL=xxx \
  -e JIANMU_NETRC_MACHINE=xxx \
  -e JIANMU_REF=xxx \
  -e JIANMU_ALI_SECRET=xxx \
  jianmudev/jianmu-runner-git-clone:${version}

# use ssh
docker run --rm \
  -e JIANMU_SSH_KEY=xxx \
  -e JIANMU_REMOTE_URL=xxx \
  -e JIANMU_NETRC_MACHINE=xxx \
  -e JIANMU_REF=xxx \
  -e JIANMU_ALI_SECRET=xxx \
  jianmudev/jianmu-runner-git-clone:${version}
```

