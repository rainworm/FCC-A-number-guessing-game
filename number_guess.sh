#!/bin/bash
PSQL="psql --username=freecodecamp --dbname=postgres -t --no-align -c"

GUESS () {
  read GUESS
  if  [[ ! $GUESS =~ ^[0-9]+$ ]]
  then
    echo "That is not an integer, guess again:"
    GUESS
  fi
  (( NUMBER_OF_GUESSES ++))

  if [[ $GUESS -lt $SECRET_NUMBER ]]
  then
    echo "It's higher than that, guess again:"
    GUESS
  fi

  if [[ $GUESS -gt $SECRET_NUMBER ]]
  then
    echo "It's lower than that, guess again:"
    GUESS
  fi
}

echo "Enter your username:"
read USERNAME

USER_ID=$($PSQL "SELECT user_id FROM users WHERE username = '$USERNAME'")

if [[ -z $USER_ID ]]
then
  echo "Welcome, $USERNAME! It looks like this is your first time here."
  INSERT_USER=$($PSQL "INSERT INTO users(username) values('$USERNAME')")
  USER_ID=$($PSQL "SELECT user_id FROM users WHERE username = '$USERNAME'")
else
  GAMES_PLAYED=$($PSQL "SELECT COUNT(*) FROM games WHERE user_id = $USER_ID")
  BEST_GAME=$($PSQL "SELECT MIN(guesses) FROM games WHERE user_id = $USER_ID")
  USERNAME_DB=$($PSQL "SELECT username FROM users WHERE user_id = $USER_ID")
  echo "Welcome back, $USERNAME_DB! You have played $GAMES_PLAYED games, and your best game took $BEST_GAME guesses."
fi

INSERT_GAME=$($PSQL "INSERT INTO games(user_id) values($USER_ID)")

GAME_ID=$($PSQL "SELECT max(game_id) FROM games WHERE user_id = $USER_ID")

SECRET_NUMBER=$(( RANDOM % 1000 + 1 ))

echo "Guess the secret number between 1 and 1000:"
NUMBER_OF_GUESSES=0
GUESS

if [[ $GUESS == $SECRET_NUMBER ]]
then
  echo "You guessed it in $NUMBER_OF_GUESSES tries. The secret number was $SECRET_NUMBER. Nice job!"
  UPDATE_GAME=$($PSQL "UPDATE games SET guesses = $NUMBER_OF_GUESSES WHERE game_id = $GAME_ID")
fi
