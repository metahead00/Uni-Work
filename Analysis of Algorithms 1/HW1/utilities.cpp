// Melike Besparmak
// 150220061
#include "tweet.h"
using namespace std;

std::vector<Tweet> readTweetsFromFile(const std::string& filename) 
{
    vector<Tweet> tweets;
    fstream file;
    file.open(filename, ios::in);
    string line, value;

    // skip first line
    getline(file, line);

    while(getline(file, line)) {
        stringstream str(line);

        getline(str, value, ',');
        long long id = stoll(value);

        getline(str, value, ',');
        int retweet = stoi(value);

        getline(str, value, ',');
        int fav = stoi(value);

        Tweet new_tweet;
        new_tweet.tweetID = id;
        new_tweet.retweetCount = retweet;
        new_tweet.favoriteCount = fav; 

        tweets.push_back(new_tweet);
    }

    file.close();
    return tweets;
}

void writeTweetsToFile(const std::string& filename, const std::vector<Tweet>& tweets) 
{
    fstream file;
    file.open(filename, ios::out);
    file << "tweetID,retweet_count,favorite_count\n";

    for(auto& t : tweets) {
        string line = to_string(t.tweetID) + ',' + to_string(t.retweetCount) + ',' + to_string(t.favoriteCount);
        file << line << "\n";
    }

    file.close();
}