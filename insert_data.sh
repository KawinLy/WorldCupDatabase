#! /bin/bash

if [[ $1 == "test" ]]
then
  PSQL="psql --username=postgres --dbname=worldcuptest -t --no-align -c"
else
  PSQL="psql --username=freecodecamp --dbname=worldcup -t --no-align -c"
fi

# Do not change code above this line. Use the PSQL variable above to query your database.

# make results deterministic for the tests
$PSQL "TRUNCATE games, teams RESTART IDENTITY;"

# read CSV (skip header)
tail -n +2 games.csv | while IFS=',' read YEAR ROUND WINNER OPPONENT WINNER_GOALS OPPONENT_GOALS
do
  # escape single quotes just in case (e.g., Cote d'Ivoire)
  WINNER_ESC=${WINNER//\'/\'\'}
  OPPONENT_ESC=${OPPONENT//\'/\'\'}

  # add teams if they don't exist
  $PSQL "INSERT INTO teams(name) VALUES('$WINNER_ESC') ON CONFLICT (name) DO NOTHING;"
  $PSQL "INSERT INTO teams(name) VALUES('$OPPONENT_ESC') ON CONFLICT (name) DO NOTHING;"

  # get team ids
  WINNER_ID=$($PSQL "SELECT team_id FROM teams WHERE name='$WINNER_ESC';")
  OPPONENT_ID=$($PSQL "SELECT team_id FROM teams WHERE name='$OPPONENT_ESC';")

  # insert the game row
  $PSQL "INSERT INTO games(year, round, winner_id, opponent_id, winner_goals, opponent_goals)
         VALUES($YEAR, '$ROUND', $WINNER_ID, $OPPONENT_ID, $WINNER_GOALS, $OPPONENT_GOALS);"
done
