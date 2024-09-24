# https://koalatea.io/python-redis-lists/
import redis
import csv
import os
from os.path import exists



REDIS_HOST =  os.environ.get('REDIS_HOST','127.0.0.1')
REDIS_PORT =  os.environ.get('REDIS_PORT', '6379')
REDIS_DB_OPT = os.environ.get('REDIS_DB_OPT', '1')
SCENARIO_ID_START = os.environ.get('SCNEARIO_ID_START', '1000')
SCENARIO_ID_LENGTH = os.environ.get('SCENARIO_ID_LENGTH' , '200')
ETA_PATH = os.environ.get('ETA_PATH' , '/opt/opt4cast/csvs/eta.csv')
 
print(REDIS_HOST, REDIS_PORT, REDIS_DB_OPT, SCENARIO_ID_START, SCENARIO_ID_LENGTH, ETA_PATH)

r = redis.Redis(host=REDIS_HOST, port=int(REDIS_PORT), db=int(REDIS_DB_OPT))
is_eta = r.rpop('ETA')
eta_exists = exists(ETA_PATH)
if is_eta != 1 and eta_exists:
    r.rpush('ETA', 1)
    
    with open('%s'%(ETA_PATH), mode ='r') as file:
        # reading the CSV file
        csvFile = csv.reader(file)
        # displaying the contents of the CSV file
        print('Uploading ETA...')
        row_counter = 0
        for row in csvFile:
            res = r.rpush(row[0], row[1], row[2], row[3])
            row_counter += 1
        print ('ETA values added: ', row_counter)
    

res = r.lrange('scenario_ids',0, -1)
print('scenario_ids size: ',len(res))
while len(res) > 0:
    res = r.lpop('scenario_ids', len(res))
    res = r.lrange('scenario_ids',0, -1)
print('scenario_ids new size',len(res))
scenario_ids_counter = 0
for i in range(int(SCENARIO_ID_START), int(SCENARIO_ID_START)+int(SCENARIO_ID_LENGTH)):
    r.rpush('scenario_ids', str(i))
    scenario_ids_counter += 1

print('Scenario IDs added: ', scenario_ids_counter)
res = r.lrange('scenario_ids',0, -1)
print('scenario_ids size: ',len(res))
