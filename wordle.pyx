import sys
import os
import random
import math
from termcolor import colored
from Letter import *
import time
import operator
import matplotlib.pyplot as plt

LEN_WORD = 5
CHANCES = 6

def printProgressBar (iteration, total, prefix = '', suffix = '', decimals = 1, length = 100, fill = '█', printEnd = "\r"):
    """
    Call in a loop to create terminal progress bar
    @params:
        iteration   - Required  : current iteration (Int)
        total       - Required  : total iterations (Int)
        prefix      - Optional  : prefix string (Str)
        suffix      - Optional  : suffix string (Str)
        decimals    - Optional  : positive number of decimals in percent complete (Int)
        length      - Optional  : character length of bar (Int)
        fill        - Optional  : bar fill character (Str)
        printEnd    - Optional  : end character (e.g. "\r", "\r\n") (Str)
    """
    percent = ("{0:." + str(decimals) + "f}").format(100 * (iteration / float(total)))
    filledLength = int(length * iteration // total)
    bar = fill * filledLength + '-' * (length - filledLength)
    print(f'\r{prefix} |{bar}| {percent}% {suffix}', end = printEnd)
    # Print New Line on Complete
    if iteration == total: 
        print()

def pick_random_word(word_list):
    word = random.choice(word_list)
    return word


def color_guess(guess, answer):
    guess_representation = []
    for i in range(LEN_WORD):
        if guess[i] == answer[i]:
            guess_representation.append(Letter(guess[i], 'green'))
        elif guess[i] in answer:
            guess_representation.append(Letter(guess[i], 'yellow'))
        else:
            guess_representation.append(Letter(guess[i], 'white'))

    return guess_representation

        
def print_guesses(guesses):
    for i in range(CHANCES):
        for j in range(LEN_WORD):
            if isinstance(guesses[i][j], str):
                print(colored(guesses[i][j], 'white'), end=' ')
            else:
                print(colored(guesses[i][j].letter, guesses[i][j].color), end=' ')
        print()


def get_possible_words(words, guesses, chances, answer):
    possible_words = []
    still_possible = True
    for word in words:
        still_possible = True
        for j in range(CHANCES-chances+1):
            for i in range(LEN_WORD):
                if (guesses[j][i].color == 'white') and (guesses[j][i].letter in word):
                    still_possible = False
                    break
                elif (guesses[j][i].color == 'green') and (guesses[j][i].letter != word[i]):
                    still_possible = False
                    break
                elif (guesses[j][i].color == 'yellow') and (guesses[j][i].letter not in word):
                    still_possible = False
                    # Need to update for double letters
                    break

        if still_possible:
            possible_words.append(word)
    #print('answer : ', answer)
    return possible_words

def get_possible_words_if_pattern(target_word, words, pattern):
    possible_words = []
    still_possible = True
    for word in words:
        still_possible = True
        for i in range(LEN_WORD):
            if pattern[i] == 'white' and target_word[i] in word:
                still_possible = False
                break
            elif pattern[i] == 'green' and target_word[i] != word[i]:
                still_possible = False
                break
            elif pattern[i] == 'yellow' and target_word[i] not in word:
                still_possible = False
                break
        
        if still_possible:
            possible_words.append(word)
    return possible_words

                
#Sequential version
def get_words_entropy(words, words_left):
    #First version, is really slow for first guess for instance. Can we do better?
    colors = ['white', 'yellow', 'green']
    entropies = [0 for i in range(len(words))]
    entropy = 0
    word_index = 0
    print("Computing entropies : ")
    for word in words:
        entropy = 0
        for color1 in colors:
            for color2 in colors:
                for color3 in colors:
                    for color4 in colors:
                        for color5 in colors:
                            possible_words = get_possible_words_if_pattern(word, words_left, [color1, color2, color3, color4, color5])
                            p = len(possible_words) / len(words_left)
                            if p != 0:
                                entropy += p * math.log(1 / p, 2)
        if word_index != len(words):
            print(f"Computing words entropy {word_index}/{len(words)}", end='\r')
        else:
            print(f"Computing words entropy {word_index}/{len(words)}")
        entropies[word_index] = (word, entropy)
        word_index += 1
    #printProgressBar(word_index, len(words), prefix = 'Progress:', suffix = 'Complete', length = 50)
    return sorted(entropies, key=operator.itemgetter(1), reverse=True)

#Parallel version
"""
def get_words_entropy_par(words, words_left):
    colors = ['white', 'yellow', 'green']
    entropies = [0 for i in range(len(words))]
    entropy = 0
    word_index = 0
    print("Computing entropies : ")
    with mp.Pool(len(words)) as p:
        for color1 in colors:
            for color2 in colors:
                for color3 in colors:
                    for color4 in colors:
                        for color5 in colors:
                            possible_words = get_possible_words_if_pattern(word, words_left, [color1, color2, color3, color4, color5])
                            p = len(possible_words) / len(words_left)
                            if p != 0:
                                entropy += p * math.log(1 / p, 2)
"""                            

def game():
    os.system('clear')
    os.system('cls')
    words = []
    possible_words = []
    guesses = [['_' for i in range(LEN_WORD)] for j in range(CHANCES)]
    with open('fr_wordlist.txt', 'r') as f:
        for line in f:
            words.append(line.strip())

    possible_words = words.copy()

    answer = pick_random_word(words)

    chances = CHANCES

    print_guesses(guesses)

    #t1 = time.time()
    #entropies = get_words_entropy(words, possible_words)
    #t2 = time.time()

    #print("Time taken to compute entropies: {}".format(t2-t1))

    #print("Best entropies", entropies[:5])

    while chances >= 1:
        guess = input()
        t1 = 0
        t2 = 0
        while len(guess) != 5:
            #print("Enter a 5 letter word : ")
            guess = input()

        os.system('clear')
        os.system('cls')

        guess_representation = color_guess(guess, answer)

        guesses[CHANCES-chances] = guess_representation

        print_guesses(guesses)

        if guess == answer:
            print('You win!')
            break

        possible_words = get_possible_words(words, guesses, chances, answer)
        
        if len(possible_words) < 100:
            print("There are {} Possible Words: {}".format(len(possible_words), possible_words))
        else:
            print("There are {} Possible Words".format(len(possible_words)))
        
        if len(possible_words) <= 10:
            t1 = time.time()
            entropies = get_words_entropy(possible_words, possible_words)
            t2 = time.time()
        else:
            t1 = time.time()
            entropies = get_words_entropy(words, possible_words)
            t2 = time.time()

        print("Time taken to compute entropies: {}".format(t2-t1))

        print("Best entropies", entropies[:5])

        chances -= 1

        print('You have ' + str(chances) + ' chances left.')

    print('The answer was ' + answer)

        

    return

def bot_game(n_games=50):
    n_tries = [0 for i in range(n_games)]

    os.system('clear')
    words = []
    possible_words = []
    guesses = [['_' for i in range(LEN_WORD)] for j in range(CHANCES)]
    win = False
    with open('fr_wordlist.txt', 'r') as f:
        for line in f:
            words.append(line.strip())

    for i in range(n_games):
        possible_words = words.copy()

        answer = pick_random_word(words)

        chances = CHANCES

        #print_guesses(guesses)

        first_try = True

        win = False

        guesses = [['_' for i in range(LEN_WORD)] for j in range(CHANCES)]

        while  chances >= 1:

            if first_try:
                guess = 'pares'
                first_try = False

            else:
                guess = entropies[0][0]

            os.system('clear')  

            guess_representation = color_guess(guess, answer)

            guesses[CHANCES-chances] = guess_representation

            print_guesses(guesses)

            if guess == answer:
                print('You win!')
                os.system('clear')
                n_tries[i] = CHANCES - chances + 1
                win = True
                break

            possible_words = get_possible_words(words, guesses, chances, answer)
            
            if len(possible_words) < 100:
                print("There are {} Possible Words: {}".format(len(possible_words), possible_words))
            else:
                print("There are {} Possible Words".format(len(possible_words)))
            
            entropies = get_words_entropy(words, possible_words)

            print("Best entropies", entropies[:5])

            chances -= 1

            print('You have ' + str(chances) + ' chances left.')
        
        if not win:
            n_tries[i] = CHANCES + 1
    
    plt.figure(figsize=(10,5))
    plt.title('Number of tries to win')
    plt.hist(n_tries, bins=range(CHANCES+2))
    plt.xlabel('Number of tries')
    plt.ylabel('Number of games')
    plt.show()

"""
if __name__ == '__main__':
    game()
"""