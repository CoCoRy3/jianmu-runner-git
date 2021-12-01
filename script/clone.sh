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

  echo ${JIANMU_NETRC_MACHINE} > /tmp/machine
  IP=`cut /tmp/machine -d ":" -f 1`
  PORT=`cut /tmp/machine -d ":" -f 2`
  echo "zc"
  FLAG=`cut /tmp/machine -d ":" -f 3`
  echo ${FLAG}
  echo "zc2"
  # compatible with non-22 ports
  if [[ -z ${FLAG} ]];then
    echo "zc3"
    ssh-keyscan -H -p ${PORT} ${IP} > ${HOME}/.ssh/known_hosts 2> /dev/null
    echo "zc4"
  else
    echo "zc5"
	  ssh-keyscan -H ${JIANMU_NETRC_MACHINE} > ${HOME}/.ssh/known_hosts 2> /dev/null
	  echo "zc6"
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
  if [[ -n "${JIANMU_PR_COMMIT_ID}" ]]; then
    # exist pr commit id
    git_init
    git fetch origin ${JIANMU_REF}
    git checkout ${JIANMU_PR_COMMIT_ID}
  else
    # not exist pr commit id
    git_init
    git fetch --depth=1 origin ${JIANMU_REF}
    git checkout FETCH_HEAD
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