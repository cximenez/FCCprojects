#! /bin/bash
PSQL="psql --username=freecodecamp --dbname=number_guess -t -c"

# user logon
echo "Enter your username: "
read USER_INPUT

# welcome message
USER_INFO=$($PSQL "SELECT username, games_played, best_game FROM users WHERE username = '$USER_INPUT';")
if [[ -z $USER_INFO ]]
then
  echo "Welcome, $USER_INPUT! It looks like this is your first time here."
  ADD_USER_RESULT=$($PSQL "INSERT INTO users(username) VALUES('$USER_INPUT');")
  USER_INFO=$($PSQL "SELECT username, games_played, best_game FROM users WHERE username = '$USER_INPUT';")
else
  echo "$USER_INFO" | while read USERNAME BAR GAMES_PLAYED BAR BEST_GAME
  do 
    echo "Welcome back, $USERNAME! You have played $GAMES_PLAYED games, and your best game took $BEST_GAME guesses."
  done
fi

# setup game variables
echo "Guess the secret number between 1 and 1000:"
NUMBER_TO_GUESS=$((1 + $RANDOM % 1000))
declare -i NUMBER_OF_GUESSES=1
echo "(Number to guess is $NUMBER_TO_GUESS)"
read NUMBER_GUESS

# require guess to be integer
while [[ ! $NUMBER_GUESS =~ ^[0-9]+$ ]]
do
  echo "That is not an integer, guess again:"
  read NUMBER_GUESS
done

# solicit guesses from user
while [[ $NUMBER_GUESS != $NUMBER_TO_GUESS ]]
do
  if [[ $NUMBER_GUESS > $NUMBER_TO_GUESS ]]
  then
    echo "It's lower than that, guess again:"
    read NUMBER_GUESS
    NUMBER_OF_GUESSES+=1
  elif [[ $NUMBER_GUESS < $NUMBER_TO_GUESS ]]
  then
    echo "It's higher than that, guess again:"
    read NUMBER_GUESS
    NUMBER_OF_GUESSES+=1
  fi
done

# update user stats
echo "$USER_INFO" | while read USERNAME BAR GAMES_PLAYED BAR BEST_GAME
do
  if [[ -z $BEST_GAME || $NUMBER_OF_GUESSES < $BEST_GAME ]]
  then
    UPDATE_USER_STATS_RESULT=$($PSQL "UPDATE users SET games_played = $(($GAMES_PLAYED + 1)), best_game = $NUMBER_OF_GUESSES WHERE username='$USERNAME';")
  else
    UPDATE_USER_STATS_RESULT=$($PSQL "UPDATE users SET games_played = $(($GAMES_PLAYED + 1)) WHERE username='$USERNAME';")
  fi
done

# print result message and stats
echo "You guessed it in $NUMBER_OF_GUESSES tries. The secret number was $NUMBER_TO_GUESS. Nice job!"
exit
