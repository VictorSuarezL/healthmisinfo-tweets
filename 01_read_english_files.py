import langdetect as lg
import pandas as pd
import glob
import os
import numpy as np

lg.DetectorFactory.seed = 123


def custom_language_detection(x):
    try:
        language = lg.detect(x)
        return language
    except:
        language = np.nan
        return language


def custom_reader(x_dir):
    # columns = ['created_at', 'id', 'text', 'geo', 'coordinates', 'place',
    #            'retweet_count', 'favorite_count', 'lang', 'user_id', 'user_name',
    #            'user_screen_name', 'user_location', 'user_verified', 'user_followers_count',
    #            'user_friends_count', 'user_favourites_count', 'user_created_at']
    columns = ['id', 'text', 'geo', 'coordinates', 'place', 'user_location']
    df = pd.read_csv(x_dir, usecols=columns, dtype='str', encoding="'utf-8'")
    df['language'] = df['text'].map(custom_language_detection, na_action='ignore')
    df = df.loc[df.language == 'en']
    print("Done!")
    print(df.shape)
    return df


file_list = glob.glob(os.path.join('..', "data_twitter", "data_csv", "*.csv"))

df_a = pd.concat(map(custom_reader, file_list[2:3]))
