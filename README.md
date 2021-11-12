# jianmu-runner-git

## git-clone

#### 介绍

用于向指定的git仓库clone项目

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
 commit_id: 将当前版本的commit id返回
```

#### 构建docker镜像

```
# 创建docker镜像
docker build -t jianmudev/jianmu-runner-git:${version} -f dockerfile/Dockerfile .

# 上传docker镜像
docker push jianmudev/jianmu-runner-git:${version}
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
  jianmudev/jianmu-runner-git:${version} \
  /usr/local/bin/clone.sh

# use ssh
docker run --rm \
  -e JIANMU_SSH_KEY=xxx \
  -e JIANMU_REMOTE_URL=xxx \
  -e JIANMU_NETRC_MACHINE=xxx \
  -e JIANMU_REF=xxx \
  jianmudev/jianmu-runner-git:${version} \
  /usr/local/bin/clone.sh
```

## git-push

#### 介绍

用于向指定的git仓库push项目

####  输入参数

```
netrc_username: git平台的账号
netrc_password: git平台的密码
ssh_key: ssh私钥
remote_url: git地址
netrc_machine: git引擎
remote_branch: 分支
source_path: 源文件路径
target_dir: 目标目录
commit_message: 提交信息
```

#### 构建docker镜像

```
# 创建docker镜像
docker build -t jianmudev/jianmu-runner-git:${vsersion} -f dockerfile/Dockerfile .

# 上传docker镜像
docker push jianmudev/jianmu-runner-git:${version}
```

#### 用法

```
# use username password
docker run --rm \
  -e JIANMU_NETRC_USERNAME=xxx \
  -e JIANMU_NETRC_PASSWORD=xxx \
  -e JIANMU_REMOTE_URL=xxx \
  -e JIANMU_NETRC_MACHINE=xxx \
  -e JIANMU_REMOTE_BRANCH=xxx \
  -e JIANMU_SOURCE_PATH=xxx \
  -e JIANMU_TARGET_DIR=xxx \
  -e JIANMU_COMMIT_MESSAGE=xxx \
  jianmudev/jianmu-runner-git:${version} \
  /usr/local/bin/push.sh

# use ssh
docker run --rm \
  -e JIANMU_SSH_KEY=xxx \
  -e JIANMU_REMOTE_URL=xxx \
  -e JIANMU_NETRC_MACHINE=xxx \
  -e JIANMU_REMOTE_BRANCH=xxx \
  -e JIANMU_SOURCE_PATH=xxx \
  -e JIANMU_TARGET_DIR=xxx \
  -e JIANMU_COMMIT_MESSAGE=xxx \
  jianmudev/jianmu-runner-git:${version} \
  /usr/local/bin/push.sh
```

