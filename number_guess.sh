#!/bin/bash
PSQL="psql --username=freecodecamp --dbname=number_guess -t --no-align -c"

GENERATE_NUMBER=$(( $RANDOM % 1000 + 1 ))
MAIN_FUNC(){
echo "Enter your username:"
read USERNAME

USER_DATA=$($PSQL "SELECT user_id, user_name, visit_count, best_guess_count FROM users WHERE user_name = '$USERNAME'")

if [[ -z $USER_DATA ]];
then
echo "Welcome, $USERNAME! It looks like this is your first time here."
$PSQL "INSERT INTO users(user_name, visit_count) VALUES('$USERNAME', 1)" > /dev/null
echo "Guess the secret number between 1 and 1000:"
SUB_FUNC "$USERNAME" "$BEST_GUESS_SO_FAR"
else
IFS='|' read ID NAME VISIT_COUNT BEST_GUESS_SO_FAR <<< "$USER_DATA"
echo "Welcome back, $USERNAME! You have played $VISIT_COUNT games, and your best game took $BEST_GUESS_SO_FAR guesses."
echo "Guess the secret number between 1 and 1000:"
VISIT_COUNT=$(( $VISIT_COUNT + 1 ))
$PSQL "UPDATE users SET visit_count = $VISIT_COUNT WHERE user_name = '$USERNAME'"  > /dev/null

SUB_FUNC "$USERNAME" "$BEST_GUESS_SO_FAR" 
fi
}

COUNT=1
SUB_FUNC(){
read INPUT

if [[ ! $INPUT =~ ^[0-9]+$ ]]
then
(( COUNT++ ))
echo "That is not an integer, guess again:"
SUB_FUNC "$USERNAME" "$BEST_GUESS_SO_FAR"
elif [[ $INPUT -gt $GENERATE_NUMBER ]]
then
(( COUNT++ ))
echo "It's lower than that, guess again:"
SUB_FUNC "$USERNAME" "$BEST_GUESS_SO_FAR"
elif [[ $INPUT -lt $GENERATE_NUMBER ]]
then
(( COUNT++ ))
echo "It's higher than that, guess again:"
SUB_FUNC "$USERNAME" "$BEST_GUESS_SO_FAR"
else
echo "You guessed it in $COUNT tries. The secret number was $GENERATE_NUMBER. Nice job!"
if [[ ! $BEST_GUESS_SO_FAR -eq 0 && $BEST_GUESS_SO_FAR -gt $COUNT || $BEST_GUESS_SO_FAR -eq 0 ]]
then
$PSQL "UPDATE users SET best_guess_count=$COUNT WHERE user_name='$USERNAME'" > /dev/null
fi
fi
}
MAIN_FUNC
