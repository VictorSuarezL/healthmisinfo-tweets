import glob
import os
import pandas as pd
from googletrans import Translator
import pycountry
import numpy as np

translator = Translator()


def custom_translator(x_trans):
    try:
        translation = translator.translate(x_trans).text
        return translation
    except:
        return x_trans


def custom_country_finder(x):
    results = []
    for country in pycountry.countries:
        if country.name in x:
            results.append(country.name)

    if not results:
        try:
            list_result = pycountry.countries.search_fuzzy(x)
            # print(results)
            [results.append(i.name) for i in list_result]
            return results

        except:
            # x = geograpy3.get_place_context(text=x).countries
            # for country in pycountry.countries:
            #     if country.name in x:
            #         results.append(country.name)
            results = np.nan
            return results
    else:
        return results


def custom_reader(x_dir):
    # columns = ['created_at', 'id', 'text', 'geo', 'coordinates', 'place',
    #            'retweet_count', 'favorite_count', 'lang', 'user_id', 'user_name',
    #            'user_screen_name', 'user_location', 'user_verified', 'user_followers_count',
    #            'user_friends_count', 'user_favourites_count', 'user_created_at']
    columns = ['id', 'text', 'geo', 'coordinates', 'place', 'user_location']
    df = pd.read_csv(x_dir, usecols=columns, dtype='str', encoding="'utf-8'")
    sel_columns = ['geo', 'coordinates', 'place', 'user_location']
    df = df.loc[df[sel_columns].notna().any(axis=1)]
    print("Done!")
    print(df.shape)
    return df


file_list = glob.glob(os.path.join('..', "data_twitter", "data_csv", "*.csv"))

df_a = pd.concat(map(custom_reader, file_list[0:4]))

# df_a['user_en'] = df_a['user_location'].apply(lambda x: custom_translator(x) if pd.notnull(x) else x)
# df_a['custom_country'] = df_a['user_location'].apply(lambda x: custom_country_finder(x) if pd.notnull(x) else x)
sel_columns = ['geo', 'coordinates', 'place', 'user_location']
df_a = df_a.loc[df_a[sel_columns].notna().any(axis=1)]

df_a.to_csv(os.path.join("..", "data_twitter", 'data_processed', "covid19_stream.csv"),
            index=False, encoding='utf-8-sig')
