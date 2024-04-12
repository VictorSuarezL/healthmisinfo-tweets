import tweepy
from datetime import datetime
import pandas as pd
import json

consumer_key = "XXXXX"
consumer_secret = "XXXXXX"
access_key = "XXXXXX"
access_secret = "XXXXXX"

records_per_file = 1000000  # Replace this with the number of tweets you want to store per file
file_path = ""  # Replace with appropriate file path followed by / where you want to store the file
count = 0
file_object = None
file_name = None


# Helper method that saves the tweets to a file at the specified path
def save_data(item):
    global file_object, count, file_name

    if file_object is None:
        file_name = int(datetime.now().timestamp() * 1e3)
        count += 1
        file_object = open(f'{file_path}covid19-{file_name}.csv', 'a')
        item.to_csv(file_object, header=True, index=False)
        return
    if count == records_per_file:
        file_object.close()
        count = 1
        file_name = int(datetime.now().timestamp() * 1e3)
        file_object = open(f'{file_path}covid19-{file_name}.csv', 'a')
        item.to_csv(file_object, header=True, index=False)
    else:
        count += 1
        item.to_csv(file_object, header=False, index=False)


# override tweepy.StreamListener to add logic to on_status
class StdOutListener(tweepy.StreamListener):
    """ A listener handles tweets that are received from the stream.
    This is a basic listener that just prints received tweets to stdout.
    """

    def __init__(self, api=None):
        super(StdOutListener, self).__init__()
        self.num_tweets = 0

    def on_data(self, data):
        print(data)
        self.num_tweets += 1
        if self.num_tweets < 6:
            try:
                tweet = json.loads(data)
                df = pd.json_normalize(tweet, sep="_")
                df = df.replace(r'\n|\r', value=' ', regex=True)
                save_data(df)

            except BaseException:
                print('Error')
                pass
            return True
        else:
            return False

    def on_error(self, status_code):
        if status_code == 420:
            return False


if __name__ == '__main__':
    l = StdOutListener()
    auth = tweepy.OAuthHandler(consumer_key, consumer_secret)
    auth.set_access_token(access_key, access_secret)

    stream = tweepy.Stream(auth, l)
    stream.filter(track=['github'])
