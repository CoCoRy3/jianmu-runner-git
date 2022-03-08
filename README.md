# jianmu-runner-git

## git-log

#### 介绍

通过git log输出日志

####  输入参数

```
git_path: git地址
```

#### 输出参数

```
 git_log: git信息
```

#### 构建docker镜像

```
# 创建docker镜像
docker build -t jianmurunner/git_log:${version} -f dockerfile/Dockerfile .

# 上传docker镜像
docker push jianmurunner/git_log:${version}
```

#### 用法

```
# use username password
docker run --rm \
  -e JIANMU_GIT_PATH=xxx \
  -e JIANMU_COMMIT_NUM=xxx \
  jianmurunner/git_log:${version} \
  /usr/local/bin/log.sh
