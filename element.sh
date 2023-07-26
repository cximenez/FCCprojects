#! /bin/bash

# Periodic Table Database Project for fCC // by Christopher Jimenez
# fix the database -- DONE
# create git repo -- DONE
# create script -- DONE 
PSQL="psql --username=freecodecamp --dbname=periodic_table -t -c"

if [[ ! $1 ]]
then
  echo "Please provide an element as an argument."
  exit
else
  INPUT=$1
fi

if [[ $INPUT =~ ^[0-9]+$ ]]
  then
  # Input is atomic number 
  INPUT_RESULT=$($PSQL "SELECT atomic_number, symbol, name FROM elements WHERE atomic_number = $INPUT;")
elif [[ $INPUT =~ ^[A-Z][a-z]?$ ]]
then
  # Input is element symbol
  INPUT_RESULT=$($PSQL "SELECT atomic_number, symbol, name FROM elements WHERE symbol = '$INPUT';")
elif [[ $INPUT =~ ^[A-Za-z]+{3,} ]]
then
  # Input is element name
  INPUT_RESULT=$($PSQL "SELECT atomic_number, symbol, name FROM elements WHERE name = '$INPUT';")
fi

if [[ -z $INPUT_RESULT ]]
then
  echo "I could not find that element in the database."
else
  echo "$INPUT_RESULT" | while read ATOMIC_NUMBER BAR SYMBOL BAR NAME
  do
    PROPERTIES=$($PSQL "SELECT groups, atomic_mass, melting_point_celsius, boiling_point_celsius FROM properties WHERE atomic_number = $ATOMIC_NUMBER;")
    echo "$PROPERTIES" | while read GROUP BAR MASS BAR MELTING_POINT BAR BOILING_POINT
    do 
      echo "The element with atomic number $ATOMIC_NUMBER is $NAME ($SYMBOL). It's a $GROUP, with a mass of $MASS amu. $NAME has a melting point of $MELTING_POINT celsius and a boiling point of $BOILING_POINT celsius."
    done
  done
fi
