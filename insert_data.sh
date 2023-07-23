#! /bin/bash

if [[ $1 == "test" ]]
then
  PSQL="psql --username=postgres --dbname=worldcuptest -t --no-align -c"
else
  PSQL="psql --username=freecodecamp --dbname=worldcup -t --no-align -c"
fi

# Do not change code above this line. Use the PSQL variable above to query your database.
echo $($PSQL "TRUNCATE games, teams")

# to do: insert data from games.csv into database
# read from games.csv, parse into 

LINE=2

cat games.csv | while IFS="," read YEAR ROUND WINNER OPPONENT WINNER_GOALS OPPONENT_GOALS
do
if [[ $YEAR != "year" ]] #don't include header line
then  
  #look for team name in database using winning teams names
  TEAM=$($PSQL "SELECT team_id FROM teams WHERE names='$WINNER'")
  # if not found then insert it into the database and check next team name
  if [[ -z $TEAM ]]
  then
    INSERT_TEAM_RESULT=$($PSQL "INSERT INTO teams(names) VALUES('$WINNER')")
    if [[ $INSERT_TEAM_RESULT == "INSERT 0 1" ]]
    then
      echo Inserted into teams, $WINNER
    fi
    #TEAM=$($PSQL "SELECT team_id FROM teams WHERE names='$WINNER'")
  fi

  #look for team name in database using opponent teams names
  TEAM=$($PSQL "SELECT team_id FROM teams WHERE names='$OPPONENT'")
  # if not found then insert it into the database and check next team name
  if [[ -z $TEAM ]]
  then
    INSERT_TEAM_RESULT=$($PSQL "INSERT INTO teams(names) VALUES('$OPPONENT')")
    if [[ $INSERT_TEAM_RESULT == "INSERT 0 1" ]]
    then
      echo Inserted into teams, $OPPONENT
    fi
    #TEAM=$($PSQL "SELECT team_id FROM teams WHERE names='$OPPONENT'")
  fi
  
  #get winner_id and opponent_id
  WINNER_ID=$($PSQL "SELECT team_id FROM teams WHERE names='$WINNER'")
  OPPONENT_ID=$($PSQL "SELECT team_id FROM teams WHERE names='$OPPONENT'")

  #insert games and data into database
  INSERT_GAMES_RESULT=$($PSQL "INSERT INTO games(year, round, winner_id, opponent_id, winner_goals, opponent_goals) 
  VALUES ($YEAR, '$ROUND', $WINNER_ID, $OPPONENT_ID, $WINNER_GOALS, $OPPONENT_GOALS)")
  if [[ $INSERT_GAMES_RESULT == "INSERT 0 1" ]]
    then
      echo Inserted into games, $YEAR, $ROUND, $WINNER_ID, $OPPONENT_ID, $WINNER_GOALS, $OPPONENT_GOALS
  fi  
fi
done
