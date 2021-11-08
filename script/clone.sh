#!/bin/bash
set -e

GIT_PROJECT=`basename "${JIANMU_REMOTE_URL}" .git`
TAGBRANCH=""

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

if [ ! -d ${JM_SHARE_DIR} ]; then
    mkdir -p ${JM_SHARE_DIR}
fi
cd ${JM_SHARE_DIR}
git clone ${JIANMU_REMOTE_URL}
cd "${GIT_PROJECT}"

#refs/heads/master
#refs/tags/1.0.0
#if ${JIANMU_REF} is tag（refs/tags/1.0.0） checkout
#if ${JIANMU_REF} is branch（refs/heads/master）checkout branch name
echo ${JIANMU_REF} > ref
CHECKOUT_REF=`cut ref -d "/" -f 3`
CHECKOUT_TYPE=`cut ref -d "/" -f 2`

if [[ ${CHECKOUT_TYPE} == "heads" ]]; then
  git checkout ${CHECKOUT_REF}
  TAGBRANCH="git_branch"
  echo "current branch:"
else
  git checkout ${JIANMU_REF}
  TAGBRANCH="git_tag"
  echo "current tags:"
fi
# echo current branch or tag
git branch

# echo commit id
echo "commit id: `git rev-parse HEAD`"

echo "resultFile:"
mkdir -p /usr/${GIT_PROJECT}
echo -e "
      {\n
          "\"git_path\"" ":" "\"${JM_SHARE_DIR}/${GIT_PROJECT}\""","\n
          "\"${TAGBRANCH}\"" ":" "\"${CHECKOUT_REF}\""","\n
          "\"commit_id\"" ":" "\"`git rev-parse HEAD`\""\n
      }
         " > resultFile
mv resultFile /usr

cat /usr/resultFile