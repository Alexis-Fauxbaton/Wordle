import sys
import os
import random
from termcolor import colored
from Letter import *

LEN_WORD = 5
CHANCES = 6

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
    print('answer : ', answer)
    return possible_words

                

def game():
    os.system('clear')
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

    while chances >= 1:
        guess = input()

        while len(guess) != 5:
            guess = input()

        os.system('clear')  

        guess_representation = color_guess(guess, answer)

        guesses[CHANCES-chances] = guess_representation

        possible_words = get_possible_words(words, guesses, chances, answer)

        print_guesses(guesses)

        if len(possible_words) < 100:
            print("There are {} Possible Words: {}".format(len(possible_words), possible_words))
        else:
            print("There are {} Possible Words".format(len(possible_words)))
        
        if guess == answer:
            print('You win!')
            break

        chances -= 1

        print('You have ' + str(chances) + ' chances left.')

    print('The answer was ' + answer)

        

    return


if __name__ == '__main__':
    game()