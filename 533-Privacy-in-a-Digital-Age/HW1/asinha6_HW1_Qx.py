import collections
import re, sys
import math, random
import numpy as np
import operator


#### BEGIN----- functions to read movie files and create db ----- ####

def add_ratings(db, chunks, num):
    if not chunks[0] in db:
        db[chunks[0]] = {}
    db[chunks[0]][num] = int(chunks[2])

def read_files(db, num):
    movie_file = "movies/"+num
    ratings = []
    fo = open(movie_file, "r")
    r = 0
    for line in fo:
        chunks = re.split(",", line)
        chunks[len(chunks)-1] = chunks[len(chunks)-1].strip()
        add_ratings(db, chunks, num)

#### END----- functions to read movie files and create db ----- ####

def score(w, p, aux, r):
    '''
    Inputs: weights of movies, maximum possible difference in rating, auxiliary information, and a record, 
    Returns the corresponding score
    '''
    #### ----- your code here ----- ####
    total_auxiliary_movies = len(aux)
    final_score = 0

    for movie in aux:
        if movie in r:
            final_score += w[movie] * ((1-( abs(aux[movie] - r[movie]) / p[movie] )) / total_auxiliary_movies)

    return final_score


def compute_weights(db):
    '''
    Input: database of users
    Returns weights of all movies
    '''
    #### ----- your code here ----- ####
    ## you can use 10 base log
    weights = {}
    movie_frequency = calculate_frequency(db)
    #compute weights
    for movie in movie_frequency:
        weights[movie] = 1/(np.log(movie_frequency[movie]))

    return weights


#### BEGIN----- additional functions ----- ####

#Adding another function dedicated to calculating frequency of each movie
def calculate_frequency(db):
    frequency_count = {}

    # Initialize and calculate the frequency for each movie
    for user_id in db:
        for movie_id in db[user_id]:
            if movie_id != 0:
                if movie_id not in frequency_count:
                    frequency_count[movie_id] = 1
                else:
                    frequency_count[movie_id] += 1

    return frequency_count

#Adding another function dedicated to calculating user scores 
def calculate_user_scores(db, auxiliary_data, movie_weights):
    min_max_ratings = calculate_min_max_ratings(db, auxiliary_data)
    rating_range = calculate_rating_range(min_max_ratings)

    user_scores = {}

    for user_id in db:
        user_scores[user_id] = score(movie_weights, rating_range, auxiliary_data, db[user_id])

    sorted_user_ids = sorted(user_scores, reverse=True, key=lambda k: user_scores[k])

    return sorted_user_ids, user_scores

#Adding another function dedicated to calculate minimum and maximum ratings
def calculate_min_max_ratings(db, aux_data):

    min_max_ratings = collections.defaultdict(list)

    for user_id in db:
        for movie_id in db[user_id]:
            db_rating = db[user_id][movie_id]

            if movie_id not in min_max_ratings:
                min_max_ratings[movie_id].append(float('inf'))
                min_max_ratings[movie_id].append(float('-inf'))

            min_max_ratings[movie_id][0] = min(min_max_ratings[movie_id][0], db_rating)
            min_max_ratings[movie_id][1] = max(min_max_ratings[movie_id][1], db_rating)

            if movie_id in aux_data:
                min_max_ratings[movie_id][0] = min(min_max_ratings[movie_id][0], aux_data[movie_id])
                min_max_ratings[movie_id][1] = max(min_max_ratings[movie_id][1], aux_data[movie_id])

    return min_max_ratings
            
#Adding another function dedicated to calculate the difference between min and max ratings. (Range)
def calculate_rating_range(ratings):
    rating_range = {}
    for movie_id in ratings:
        rating_range[movie_id] = abs(ratings[movie_id][0] - ratings[movie_id][1])

    return rating_range

#Adding another function dedicated to answering Q1-c
def solution_1c(user_ids, db, aux):

    max_user_id = user_ids[0]
    print('The user-id of the user with highest score in aux is {}\n'.format(max_user_id))

    # Working on printing movie ratings of this user from the database, side-by-side with the ratings from the auxiliary
    max_user_ratings = db[max_user_id]
    db_list_ratings = []
    aux_list_ratings = []

    # Create dictionaries to store ratings by movie ID
    db_ratings_dict = {k: v for k, v in max_user_ratings.items()}
    aux_ratings_dict = {k: v for k, v in aux.items()}

    # Iterate over all movie IDs from both databases
    all_movie_ids = set(db_ratings_dict.keys()) | set(aux_ratings_dict.keys())

    for movie_id in all_movie_ids:
        db_rating = db_ratings_dict.get(movie_id, "N/A")
        aux_rating = aux_ratings_dict.get(movie_id, "N/A")

        db_list_ratings.append('{}: {}'.format(movie_id, db_rating))
        aux_list_ratings.append('{}: {}'.format(movie_id, aux_rating))

    # Print the ratings side-by-side for comparison
    print('Movie Ratings from dB and aux side by side:')
    for db_rating, aux_rating in zip(db_list_ratings, aux_list_ratings):
        print(f'Database: {db_rating}\tAuxiliary: {aux_rating}')

def calculate_m(auxiliary_data, movie_weights):
    metric_score = 0
    length_auxiliary = len(auxiliary_data)
    for movie_id in auxiliary_data:
        metric_score += (movie_weights[movie_id] / length_auxiliary)

    return metric_score



#### END----- additional functions ----- ####

if __name__ == "__main__":
    db = {}
    files = ["03124", "06315", "07242", "16944", "17113",
            "10935", "11977", "03276", "14199", "08191",
            "06004", "01292", "15267", "03768", "02137"]

    for file in files:
        read_files(db, file)

    aux = {'03124': 3.5, '16944': 2.5, '17113': 4, '10935': 2, '11977': 2, '03276': 2.5, '14199': 3.5, '06004': 1.5, '01292': 2, '03768': 1.5, '02137': 1.5}

    #First Question 1-a
    w = compute_weights(db)
    print("Solution to 1a")
    print('Movie: Weight')
    print()

    for movie,weights in w.items():
        print('{}: {}'.format(movie, weights))
    print()

    #Working on 1-b
    sorted_ids,user_score = calculate_user_scores(db,aux, w)
    highest_scores = sorted_ids[:5]  # Get the first 5 values

    print('Solution to 1b')
    print('Top 5 most similar user ids are: {}'.format(highest_scores))
    print()

    #Working on 1c
    print('Solution to 1c')
    solution_1c(sorted_ids, db, aux)
    print()

    #Working on 1-d
    print('Solution to 1d')
    highest_score = user_score[sorted_ids[0]]
    second_highest = user_score[sorted_ids[1]]
    print('Difference between highest and second highest score is {}'.format(highest_score - second_highest))
    print('Working on checking whether or not we accept the candidate:')
    print()
    
    #checking and calculating value of the threshold
    print('First, assuming that the value of gamma is 0.1,')
    threshold = 0.1*(calculate_m(aux, w))
    print('Value of gamma*M is {}'.format(threshold))
    is_difference_greater_than_threshold = (highest_score - second_highest) > threshold

    if is_difference_greater_than_threshold:
        print('Yes, the difference is greater than the threshold.')
        print('Therefore, we can accept the candidate')
    else:
        print('No, the difference is not greater than the threshold.')
        print('Therefore, we cannot accept the candidate')

    print()
    print('Now assuming gamma is 0.05')
    threshold = 0.05*(calculate_m(aux, w))
    print('Value of gamma*M is {}'.format(threshold))
    is_difference_greater_than_threshold = (highest_score - second_highest) > threshold

    if is_difference_greater_than_threshold:
        print('Yes, the difference is greater than the threshold.')
        print('Therefore, we can accept the candidate')
    else:
        print('No, the difference is not greater than the threshold.')
        print('Therefore, we cannot accept the candidate')

    #### ----- your code here ----- ####



    
