#!/bin/bash
set -e

GIT_PROJECT=`basename "${JIANMU_REMOTE_URL}" .git`

if [[ -z "${JIANMU_REMOTE_URL}" ]]
then
  echo "[ERROR] The necessary git source configuration is missing"
  exit 1
fi

# write in username password
if [[ -n "${JIANMU_USERNAME}" && -n "${JIANMU_PASSWORD}" ]]
then
  # check url
  echo ${JIANMU_REMOTE_URL} > url
  URL_FLAG=`cut url -d "@" -f 2`
  if [[ ${URL_FLAG} != "${JIANMU_REMOTE_URL}" ]]; then
    echo "[ERROR] url configuration error"
    exit 1
  fi

  NETRC_MACHINE=`echo ${JIANMU_REMOTE_URL} | awk -F "//" '{print $2}' | awk -F "/" '{print $1}' | awk -F ":" '{print $1}'`
  echo "machine: ${NETRC_MACHINE}"

  mkdir -p ${HOME}
  	cat <<EOF > ${HOME}/.netrc
  machine ${NETRC_MACHINE}
  login ${JIANMU_USERNAME}
  password ${JIANMU_PASSWORD}
EOF
  chmod 600 ${HOME}/.netrc
else
  echo "[WARN] The username or password configuration is missing,try use ssh"
fi

# write in ssh key
if [[ -n "${JIANMU_SSH_KEY}" ]]; then
  # check url
   echo ${JIANMU_REMOTE_URL} > url
    URL_FLAG=`cut url -d "@" -f 2`
    if [[ ${URL_FLAG} == "${JIANMU_REMOTE_URL}" ]]; then
      echo "[ERROR] url configuration error"
      exit 1
    fi

	mkdir -p ${HOME}/.ssh
	echo -n "$JIANMU_SSH_KEY" > ${HOME}/.ssh/id_rsa
	chmod 600 ${HOME}/.ssh/id_rsa

  touch ${HOME}/.ssh/known_hosts
	chmod 600 ${HOME}/.ssh/known_hosts

	# compatible default port is not 22
  HAS_PORT=`echo ${JIANMU_REMOTE_URL} | awk -F ":" '{print $1}'`
  if [ ${HAS_PORT} == "ssh" ]; then
      NETRC_MACHINE=`echo ${JIANMU_REMOTE_URL} | awk -F "@" '{print $2}' | awk -F "/" '{print $1}'`
      echo ${NETRC_MACHINE} > /tmp/machine
      IP=`cut /tmp/machine -d ":" -f 1`
      PORT=`cut /tmp/machine -d ":" -f 2`
      ssh-keyscan -H -p ${PORT} ${IP} > ${HOME}/.ssh/known_hosts 2> /dev/null
  else
      NETRC_MACHINE=`echo ${JIANMU_REMOTE_URL} | awk -F "@" '{print $2}' | awk -F ":" '{print $1}'`
      ssh-keyscan -H ${NETRC_MACHINE} > ${HOME}/.ssh/known_hosts 2> /dev/null
  fi
else
  echo "[WARN] The SSH configuration is missing,try use username,password"
fi

# git clone
cd /
git clone ${JIANMU_REMOTE_URL}
cd ${GIT_PROJECT}
git checkout ${JIANMU_REMOTE_BRANCH}

# handle path
if [[ ! "${JIANMU_TARGET_DIR}:0:1" == "/" ]]; then
      JIANMU_TARGET_DIR="/"${JIANMU_TARGET_DIR}
fi

# target_dir must be a directory
if [ -f ${JIANMU_TARGET_DIR} ]; then
    echo "[ERROR] target_dir must be a directory."
    exit 1
else
  if [ ! -d ${JIANMU_TARGET_DIR} ]; then
      mkdir -p ${JIANMU_TARGET_DIR}
  fi
fi

git_push() {
    # git push
    git config --global user.email "${JIANMU_COMMITTER_EMAIL}"
    git config --global user.name "${JIANMU_COMMITTER_NAME}"
    git add .

    echo `git commit -m "${JIANMU_COMMIT_MESSAGE}"`
    git push ${JIANMU_REMOTE_URL} ${JIANMU_REMOTE_BRANCH}
    exit 0
}

# source_path is a directory
if [ -d ${JIANMU_SOURCE_PATH} ]; then
    # cp source file
    echo y | cp -r ${JIANMU_SOURCE_PATH}/* ${JIANMU_TARGET_DIR}

    git_push
fi

# source_path is a file
if [ -f ${JIANMU_SOURCE_PATH} ]; then
    # cp source file
    echo y | cp ${JIANMU_SOURCE_PATH} ${JIANMU_TARGET_DIR}

    git_push
fi

