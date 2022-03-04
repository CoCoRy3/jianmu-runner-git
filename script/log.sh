#!/bin/bash
set -e

cd "${JIANMU_GIT_PATH}"
# 1. Extract log
git log --pretty=format:"%H 「……」 %an 「……」 %ae 「……」 %cn 「……」 %ce 「……」 %cd 「……」 %s" > log
# 2. Format and generate output using Python
python /usr/local/bin/log2json.py