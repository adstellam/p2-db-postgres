#!/usr/bin/env python

##
## The PL/pgsql function ``s_update_cultivator_trace``` called by the callproc()
## method must have four args of the following data type:
##      arg0: cultivator_id STR
##      arg1: utc_datetime_in_iso_fomat STR
##      arg2: coordinate_lon FLOAT
##      arg3: coordinate_lat FLOAT
## 
## The PL/pgsql function ``s_update_cultivator_pos``` called by the callproc()
## method must have two args of the following data type:
##      arg0: cultivator_id STR
##      arg1: pos STR [a serialized JSON object with three properties: lon, lat, and ts
##

import threading
import asyncio
import json
import datetime
import time
import logging
import signal
import websockets
import psycopg2

logging.basicConfig(level=logging.INFO)
logging.getLogger('asyncio').setLevel(logging.INFO)

with open('cultivator_ip.json', 'r') as fs: 
    cultivator_ip_dict = json.load(fs)
cultivator_ws_port = 9999

conn = psycopg2.connect(host="localhost", port=5432, database="postgres", user="api", password="$tout")
cur = conn.cursor()

async def update_cultivator_trace_and_pos_with_websocket_data(cid):
    uri = f'ws://{cultivator_ip_dict[cid]}:{cultivator_ws_port}'
    async with websockets.connect(uri) as ws:
        while True:
            msg = await ws.recv()
            utcnow = datetime.datetime.utcnow().isoformat()
            data = json.loads(msg)
            logging.debug(f'{cid}: {utcnow}, {data["lon"]}, {data["lat"]}')
            if float(data["lon"]) != 0 and float(data["lat"]) != 0:  
                cur.callproc("insert_into_cultivator_trace_table", (cid, utcnow, float(data["lon"]), float(data["lat"])))
                pos = f'{{ "lon": {float(data["lon"])}, "lat": {float(data["lat"])}, "ts": "{utcnow}" }}'
                cur.callproc("s_update_cultivator_pos", (cid, pos))
                cur.execute("commit;")
        
def run_asyncio_loop(cid):
    try:
        asyncio.run(update_cultivator_trace_and_pos_with_websocket_data(cid), debug=True)
    except (ConnectionError, TimeoutError):
        logging.info('websockets.connect() failed.')

def main():
    for cid in cultivator_ip_dict.keys():
        t = threading.Thread(name=f'{cid}', target=run_asyncio_loop, args=(cid,), daemon=False)    
        t.start()
    while True:         
        time.sleep(60)
        active_thread_names = [t.name for t in threading.enumerate()]
        logging.info(f'The number of active threads: {len(active_thread_names)}')
        for cid in cultivator_ip_dict.keys():
            if not cid in active_thread_names:
                t = threading.Thread(name=f'{cid}', target=run_asyncio_loop, args=(cid,), daemon=False)    
                t.start()
                logging.info(f'Thread {cid} restarted')

try:
    main()
except KeyboardInterrupt:
    logging.info('Keyboard Interrupt')
finally:
    cur.close()
    conn.close()


