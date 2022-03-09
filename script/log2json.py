import datetime
import json
import os

path = os.getenv("JIANMU_GIT_PATH")
commit_num = os.getenv("JIANMU_COMMIT_NUM")

print(commit_num)

f = open(f'{path}/log', 'r', encoding="utf-8")
resultList = []
std_transfer = '%a %b %d %H:%M:%S %Y %z'
logs = f.readlines()

frequency = 0
for log in logs:
    frequency += 1
    logList = log.split(" 「……」 ")
    std_create_time = datetime.datetime.strptime(logList[5], std_transfer)
    time = (std_create_time + datetime.timedelta(hours=-8)).strftime('%Y-%m-%dT%H.%M.%S')
    logDict = {
        "hashValue": logList[0],
        "authorName": logList[1],
        "authorEmailAddress": logList[2],
        "committerName": logList[3],
        "committerEmailAddress": logList[4],
        "commitDate": time,
        "commitExplain": logList[6]
    }
    resultList.append(logDict)
    if frequency == commit_num:
        break

print(json.dumps(resultList, sort_keys=True, indent=4, separators=(',', ':'), ensure_ascii=False))

json_data = json.dumps(resultList, ensure_ascii=False)
logs = {'git_log': json_data}
result = json.dumps(logs, ensure_ascii=False)

# 生成结果
resultFile = open('/tmp/resultFile', 'w', encoding='utf-8')
resultFile.write(result)
resultFile.close()
