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

def game():
    os.system('clear')
    words = []
    guesses = [['_' for i in range(LEN_WORD)] for j in range(CHANCES)]
    with open('fr_wordlist.txt', 'r') as f:
        for line in f:
            words.append(line.strip())

    answer = pick_random_word(words)
    
    chances = CHANCES

    print_guesses(guesses)

    while chances >= 1:
        guess = input()

        while len(guess) != 5:
            guess = input()

        guess_representation = color_guess(guess, answer)

        guesses[CHANCES-chances] = guess_representation

        print_guesses(guesses)

        if guess == answer:
            print('You win!')
            break
        
        os.system('clear')  

        chances -= 1

        print('You have ' + str(chances) + ' chances left.')

    print('The answer was ' + answer)

        

    return


if __name__ == '__main__':
    game()