import json
import datetime
import os

path = os.getenv("JIANMU_GIT_PATH")

f = open(f'{path}/log', 'r', encoding="utf-8")
resultList = []
std_transfer = '%a %b %d %H:%M:%S %Y %z'
logs = f.readlines()
for log in logs:
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
json_data = json.dumps(resultList, ensure_ascii=False)
logs = {'log': json_data}
result = json.dumps(logs, ensure_ascii=False)
print(result)

# 生成结果
resultFile = open('/tmp/resultFile', 'w', encoding='utf-8')
resultFile.write(result)
resultFile.close()
