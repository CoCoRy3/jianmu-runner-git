### jianmu-runner-git-clone

**介绍：**

用于向指定的git引擎clone项目

**版本：**

jianmu-runner-git-clone:1.0.0

**参数：**

- 输入参数

  ```
  - name: 用户名
    ref: netrc_username
    type: SECRET
    value: xxx
    description: git平台的账号
    
  - name: 密码
    ref: netrc_password
    type: SECRET
    value: xxx
    description: git平台的密码
    
  - name: ssh私钥
    ref: ssh_key
    type: SECRET
    value: xxxx
    description: 平台中设置的ssh公钥对应的私钥(id_rsa)
    
  - name: git地址
    ref: remote_url
    type: STRING
    value: xxxx
    description: 配置远程的git源,即从哪个url上clone项目:使用账号密码的方式的url"https://gitee.com/jianmu_dev/jianmu-ci-ui.git"
                 或者使用ssh的方式的url"git@gitee.com:jianmu_dev/jianmu-ci-ui.git"
    						 
  - name: git引擎
    ref: netrc_machine
    type: STRING
    value: gitee.com
    description: gitee.com,github.com,gitlab.com等等
    
  - name: 标签或分支
    ref: ref
    type: STRING
    value: refs/heads/master
    description: 需要git的标签或者分支,如果是branch则格式为："/refs/heads/master",
    			 如果是tag则格式为："/refs/tags/1.0.0"
    						 
  ```

- 输出参数

  ```
  - ref: git_path
    name: git clone目录
    type: STRING
    value: xxxx
    description: 会将clone完成后的项目存放的地址以绝对路径的方式返回
    
  - ref: git_branch
    name: git分支
    type: STRING
    value: xxxx
  	description: 如果选择git分支,则会将此分支名返回,如：master,git_tag参数和git_branch参数只会返回一个
  	
  - ref: git_tag
    name: git tags
    type: STRING
    value: xxxx
    description: 如果选择某个标签,则会将此标签返回,如：1.0.0,git_tag参数和git_branch参数只会返回一个
  
  ```

  