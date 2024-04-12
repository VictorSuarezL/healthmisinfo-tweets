import pandas as pd
import json
#
# tweets_file = open("/Volumes/TOSHIBA EXT/01_pycharm/splited202001311428_stream.json_00.json",
#             "r")
#
# with tweets_file as fh:
#     track_response = json.load(tweets_file)
#
# tweets_file.close()
#
# print(track_response.keys())
#
# track_response = pd.json_normalize(track_response)
#
# print(track_response.keys())

tweets_file = open("/Volumes/TOSHIBA EXT/01_pycharm/splited202001311428_stream.json_00.json",
                   "r")

tweets_data = []

with tweets_file as fh:
    for line in fh:
        if line.startswith("{"):
            try:
                line_object = json.loads(line)
                tweets_data.append(line_object)
            except:
                pass

df = pd.json_normalize(tweets_data, sep='_')
df = pd.DataFrame(df)

df.to_csv('test1.csv')
