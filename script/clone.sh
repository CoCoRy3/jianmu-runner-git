#!/bin/bash
set -e

GIT_PROJECT=`basename "${JIANMU_REMOTE_URL}" .git`

if [[ -z "${JIANMU_REMOTE_URL}" ]]
then
  echo "[ERROR] The necessary git source configuration is missing"
  exit 1
fi

# write in username password
if [[ -n "${JIANMU_NETRC_USERNAME}" && -n "${JIANMU_NETRC_PASSWORD}" ]]
then
  NETRC_MACHINE=`echo ${JIANMU_REMOTE_URL} | awk -F "//" '{print $2}' | awk -F "/" '{print $1}'`

  mkdir -p ${HOME}
  	cat <<EOF > ${HOME}/.netrc
  machine ${NETRC_MACHINE}
  login ${JIANMU_NETRC_USERNAME}
  password ${JIANMU_NETRC_PASSWORD}
EOF
  chmod 600 ${HOME}/.netrc
else
  echo "[WARN] The username or password configuration is missing,try use ssh"
fi

# write in ssh key
if [[ -n "${JIANMU_SSH_KEY}" ]]; then
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

if [ ! -d ${JM_SHARE_DIR} ]; then
    mkdir -p ${JM_SHARE_DIR}
fi
cd ${JM_SHARE_DIR}
mkdir -p ${GIT_PROJECT}
cd ${GIT_PROJECT}

git_init() {
  git init
  git remote add origin ${JIANMU_REMOTE_URL}
}

git_tag() {
  REF_KEY="git_tag"
  REF_VALUE=
  git_init
  git fetch --depth=1 origin ${JIANMU_REF}
  git checkout -qf FETCH_HEAD
}

git_branch() {
  echo ${JIANMU_REF} > ref
  CHECKOUT_BRANCH=`cut ref -d "/" -f 3`
  # exist commit id
  if [[ -n "${JIANMU_COMMIT_ID}" ]]; then
    git_init
    git fetch origin ${JIANMU_REF}
    git checkout ${JIANMU_COMMIT_ID} -b ${CHECKOUT_BRANCH}
  else
    # not exist commit id
    git_init
    git fetch --depth=1  origin ${JIANMU_REF}
    git checkout FETCH_HEAD
  fi
}

git_pr() {
  git fetch --depth=1 origin +refs/heads/${JIANMU_PR_COMMIT_BRANCH}:
  git checkout ${JIANMU_PR_COMMIT_BRANCH}
  if [[ -n "${JIANMU_COMMIT_ID}" ]]; then
    # exist pr commit id
    git_init
    git fetch origin ${JIANMU_REF}
    git merge ${JIANMU_COMMIT_ID}
  else
    # not exist pr commit id
    git_init
    git fetch --depth=1 origin ${JIANMU_REF}
    git merge FETCH_HEAD
  fi
}

case ${JIANMU_REF} in
  refs/tags/*  ) git_tag ;;
  refs/heads/* ) git_branch ;;
             * ) git_pr ;;
esac

# echo git log
echo "git log: "
git log

echo "resultFile:"
echo -e "{
     "\"git_path\"" ":" "\"${JM_SHARE_DIR}/${GIT_PROJECT}\""","
     "\"git_ref\"" ":" "\"${JIANMU_REF}\""","
     "\"commit_id\"" ":" "\"`git rev-parse HEAD`\""
}" > resultFile
mv resultFile /usr

cat /usr/resultFile