"""This code grabs submission and comment data for r/WritingPrompts
within given time bounds. It uses PRAW and PSAW packages for easy scraping.
It can easily be modified to grab info for other subreddits.
I've anonymized the initialization details for PRAW.
Data is saved to two csv files, one for comments and one for submissions.
Just as a heads-up, a week's worth of comment data comes out to ~45MB.
"""

import praw
import datetime as dt
import pandas as pd
from psaw import PushshiftAPI

# Destination files. The numbers i_to_j_on_k indicate selection from April i to April j, taken on April k.
SUBMISSION_DEST_FILE = "wp_raw_subm_apr4_to_apr13_on_apr17.csv"
COMMENT_DEST_FILE = "wp_raw_comm_apr4_to_apr13_on_apr17.csv"

# Which subreddit?
TARGET_SUB = "WritingPrompts"

# Initialization details for PRAW
CLIENT_ID = 'your_id'
CLIENT_SECRET = 'your_secret'
USER_AGENT = 'your_agent'

# Time bounds. Format is (year, month, day).
START_EPOCH = int(dt.datetime(2020, 4, 4).timestamp())
END_EPOCH = int(dt.datetime(2020, 4, 13).timestamp())

if __name__ == "__main__":
    r = praw.Reddit(client_id=CLIENT_ID, client_secret=CLIENT_SECRET, user_agent=USER_AGENT)
    api = PushshiftAPI(r)

    # Get submission data
    submission_gen = api.search_submissions(subreddit=TARGET_SUB, after=START_EPOCH)
    df = pd.DataFrame([submission.__dict__ for submission in submission_gen])
    df.to_csv(path_or_buf=SUBMISSION_DEST_FILE)

    # Get comment data
    comment_gen = api.search_comments(subreddit="WritingPrompts", after=START_EPOCH)
    df2 = pd.DataFrame([comment.__dict__ for comment in comment_gen])
    df2.to_csv(path_or_buf=COMMENT_DEST_FILE)
