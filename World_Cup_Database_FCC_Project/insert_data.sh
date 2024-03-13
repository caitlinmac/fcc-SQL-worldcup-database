#! /bin/bash

if [[ $1 == "test" ]]
then
  PSQL="psql --username=postgres --dbname=worldcuptest -t --no-align -c"
else
  PSQL="psql --username=freecodecamp --dbname=worldcup -t --no-align -c"
fi

# Do not change code above this line. Use the PSQL variable above to query your database.

#Script to insert data from games.csv into worldcup database 

#0. Set up 
 #0.1 use cat to 'print' the contents of csv file: 'cat games.csv'
 #0.2 use a while loop so you can 'pipe' the output of cat and sort through it one row at a time
 #0.3 set the IFS "Internal Field Separator" to separate the words/data from the csv file

cat games.csv | while IFS="," read YEAR ROUND WINNER OPPONENT WINNER_GOALS OPPONENT_GOALS
do

#1 teams Table: Get unique info - winner and opponent, check if they exist, if not then add them

#1.1 exclude title rows
if [[ $WINNER != winner ]] #exclude title row for winner
then
if [[ $OPPONENT != opponent ]] #exclude title row for opponent
then

#1.2 Check if winner team is already in table by querying value in teams(name)
TEAM1_ID=$($PSQL "SELECT name FROM teams WHERE name='$WINNER';")

#1.3 If NOT found already in teams(name)
if [[ -z $TEAM1_ID ]]
then

#1.3.1 Then insert into teams(name)
INSERT_TEAM1_RESULT=$($PSQL "INSERT INTO teams (name) VALUES('$WINNER');")

if [[ $INSERT_TEAM1_RESULT == "INSERT 0 1" ]] ##nicer message to show successful insert into teams(name)
then 
echo Inserted into teams, $WINNER
fi

fi

#1.3.4 get opponent
TEAM2_ID=$($PSQL "SELECT name FROM teams WHERE name='$OPPONENT';")

#1.3.5 if not found already in teams(name)
if [[ -z $TEAM2_ID ]]
then

#1.3.6 then insert into teams(name)
INSERT_TEAM2_RESULT=$($PSQL "INSERT INTO teams (name) VALUES('$OPPONENT');")

if [[ $INSERT_TEAM2_RESULT == "INSERT 0 1" ]] ##nicer message to show successful insert into teams(name)
then 
echo Inserted into teams, $OPPONENT
fi

fi

fi
fi

#2. Add GAMES info and link to the team_id
GAME_WINNER_ID=$($PSQL "SELECT team_id FROM teams WHERE name='$WINNER';")
GAME_OPPONENT_ID=$($PSQL "SELECT team_id FROM teams WHERE name='$OPPONENT';")

INSERT_GAME_INFO=$($PSQL "INSERT INTO games (year, round, winner_id, opponent_id, winner_goals, opponent_goals) VALUES( $YEAR, '$ROUND', $GAME_WINNER_ID, $GAME_OPPONENT_ID, $WINNER_GOALS, $OPPONENT_GOALS);")

if [[ $INSERT_GAME_INFO == "INSERT 0 1" ]] ##nicer message to show successful insert into games
then 
echo Inserted into games, $YEAR, $ROUND, $GAME_WINNER_ID, $GAME_OPPONENT_ID, $WINNER_GOALS, $OPPONENT_GOALS
fi

done
