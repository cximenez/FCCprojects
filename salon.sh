#! /bin/bash

# Bash script to run a salon using PostgreSQL for fCC relational database project// by Chris Jimenez

PSQL="psql -X --username=freecodecamp --dbname=salon --tuples-only -c"

echo "Welcome to Corgi Salon. For what service would you like to schedule an appointment?"

MAIN_MENU() {
  # list services
  SERVICES=$($PSQL "SELECT service_id, name FROM services;")
  echo "$SERVICES" | while read SERVICE_ID BAR NAME
  do
    echo -e "$SERVICE_ID)" $NAME
  done
  # ask for user selection until valid option is selected
  read SERVICE_ID_SELECTED
  if [[ ! $SERVICE_ID_SELECTED =~ [1-3] ]]
  then
    echo -e "\nPlease choose a valid service"
    MAIN_MENU
  else
    BOOK $SERVICE_ID_SELECTED
  fi 
}

BOOK() {
  # process service request and ask for phone number
  #SERVICE_ID_SELECTED=$($PSQL "SELECT service_id FROM services WHERE service_id = $SERVICE_ID")
  
  echo -e "\nWhat is a good phone number to reach you?"
  read CUSTOMER_PHONE
  CUSTOMER_ID=$($PSQL "SELECT customer_id FROM customers WHERE phone = '$CUSTOMER_PHONE';")
  #echo -e "'\nGreat. And your name?"
  #read CUSTOMER_NAME

  
  # if phone number shows customer doesn't exist in database
  if [[ -z $CUSTOMER_ID ]] 
  then
    # get name and enter new customer data into database
    echo -e "\nLooks like you are a new customer for us. Your name again?"
    read CUSTOMER_NAME
    INSERT_NEW_CUSTOMER_RESULT=$($PSQL "INSERT INTO customers(name, phone) VALUES('$CUSTOMER_NAME', '$CUSTOMER_PHONE');") 
    CUSTOMER_ID=$($PSQL "SELECT customer_id FROM customers WHERE phone = '$CUSTOMER_PHONE';")
  #else
    #echo -e "\nWelcome back. And a name for the booking?"
    #read CUSTOMER_NAME
  fi
  CUSTOMER_ID=$($PSQL "SELECT customer_id FROM customers WHERE phone = '$CUSTOMER_PHONE';")
  CUSTOMER_NAME=$($PSQL "SELECT name FROM customers WHERE customer_id = '$CUSTOMER_ID';")
  CUSTOMER_NAME_FORMATTED=$(echo $CUSTOMER_NAME | sed -r 's/^ *| *$//g')
  
  # ask for appointment time and confirm appointment
  echo -e "\nThanks, $CUSTOMER_NAME_FORMATTED. What time will work for you?"
  read SERVICE_TIME
  INSERT_TIME_RESULT=$($PSQL "INSERT INTO appointments(customer_id, service_id, time) VALUES($CUSTOMER_ID, $SERVICE_ID_SELECTED, '$SERVICE_TIME');")
  
  SERVICE_NAME=$($PSQL "SELECT name FROM services WHERE service_id = $SERVICE_ID_SELECTED;")
  SERVICE_NAME_FORMATTED=$(echo $SERVICE_NAME | sed -r 's/^ *| *$//g')
  echo "I have put you down for a "${SERVICE_NAME_FORMATTED,,}" at $SERVICE_TIME, $CUSTOMER_NAME_FORMATTED."
}

MAIN_MENU