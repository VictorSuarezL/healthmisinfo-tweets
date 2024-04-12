import pandas as pd
import sys
import json
from os import remove


for filename in sys.argv[1:]:

    if len(filename) > 1:
        line_generator = open(filename)

    print(filename)

    tweets_data = []

    for line in line_generator:
        if line.startswith("{"):
            try:
                line_object = json.loads(line)
                tweets_data.append(line_object)
            except:
                pass

    line_generator.close()

    df = pd.json_normalize(tweets_data, sep='_')
    df = pd.DataFrame(df).replace({r'\r\n': '',
                                   r'\n': '',
                                   r'\r': ''}, regex=True)

    remove(filename)

    # TODO: remove id_str (='id')

    columns_to_write = ['created_at', 'id', 'text', 'truncated', 'in_reply_to_status_id',
                        'in_reply_to_user_id', 'geo', 'coordinates', 'place', 'retweet_count',
                        'favorite_count', 'retweeted', 'lang',
                        'user_id', 'user_name', 'user_screen_name', 'user_location',
                        'user_verified', 'user_followers_count', 'user_friends_count',
                        'user_favourites_count', 'user_statuses_count', 'user_created_at',
                        'user_time_zone', 'user_lang', 'extended_tweet_full_text',
                        'retweeted_status_id', 'retweeted_status_user_id_str',
                        'retweeted_status_user_verified', 'retweeted_status_user_followers_count',
                        'retweeted_status_user_friends_count', 'retweeted_status_extended_tweet_full_text',
                        'retweeted_status_retweet_count', 'retweeted_status_favorite_count',
                        'possibly_sensitive', 'retweeted_status_possibly_sensitive']

    # Print head of DataFrame
    df.to_csv(filename + '.csv', index=False, header=True, columns=columns_to_write)

    print(f'Succesfully write {filename}\n')
