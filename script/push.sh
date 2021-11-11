#!/bin/bash
set -e

GIT_PROJECT=`basename "${JIANMU_REMOTE_URL}" .git`

if [[ -z "${JIANMU_REMOTE_URL}" ]]
then
  echo "[ERROR] The necessary git source configuration is missing"
  exit 1
fi

if [[ -z "${JIANMU_NETRC_MACHINE}" ]]; then
  echo "[WARN] The git machine configuration is missing"
fi

if [[ -n "${JIANMU_NETRC_USERNAME}" && -n "${JIANMU_NETRC_PASSWORD}" ]]
then
  mkdir -p ${HOME}
  	cat <<EOF > ${HOME}/.netrc
  machine ${JIANMU_NETRC_MACHINE}
  login ${JIANMU_NETRC_USERNAME}
  password ${JIANMU_NETRC_PASSWORD}
EOF
  chmod 600 ${HOME}/.netrc
else
  echo "[WARN] The username or password configuration is missing,try use ssh"
fi


if [[ -n "${JIANMU_SSH_KEY}" ]]; then
	mkdir -p ${HOME}/.ssh
	echo -n "$JIANMU_SSH_KEY" > ${HOME}/.ssh/id_rsa
	chmod 600 ${HOME}/.ssh/id_rsa

	touch ${HOME}/.ssh/known_hosts
	chmod 600 ${HOME}/.ssh/known_hosts
	ssh-keyscan -H ${JIANMU_NETRC_MACHINE} > ${HOME}/.ssh/known_hosts 2> /dev/null
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
    git config --global user.email "jianmu@example.com"
    git config --global user.name "jianmu push"
    git add .

    git commit -m "${JIANMU_COMMIT_MESSAGE}"
    git push ${JIANMU_REMOTE_URL} ${JIANMU_REMOTE_BRANCH}
    exit 0
}

# source_path is a directory
if [ -d ${JIANMU_SOURCE_PATH} ]; then
    # cp source file
    cp -r ${JIANMU_SOURCE_PATH}/* ${JIANMU_TARGET_DIR}

    git_push
fi

# source_path is a file
if [ -f ${JIANMU_SOURCE_PATH} ]; then
    # cp source file
    cp ${JIANMU_SOURCE_PATH} ${JIANMU_TARGET_DIR}

    git_push
fi

