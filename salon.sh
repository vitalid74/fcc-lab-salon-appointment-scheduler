#!/bin/bash
PSQL="psql --username=freecodecamp --dbname=salon --tuples-only --no-align -c " 

# $($PSQL "TRUNCATE TABLE services, customers, appointments RESTART IDENTITY CASCADE;")
# $($PSQL "INSERT INTO services(name) VALUES ('cut'),('color'), ('perm'),('style'),('trim');")


echo -e "\n~~~~~ MY SALON ~~~~~"

MAIN_MENU() {
  if [[ $1 ]]
  then
    echo -e "\n$1"
    MAIN_MENU
  else
    echo -e "\nWelcome to My Salon, how can I help you?\n"

    echo "$($PSQL "SELECT * FROM services ORDER BY service_id;")" | while IFS="|" read SERVICE_ID SERVICE_NAME 
    do
      echo "$SERVICE_ID) $SERVICE_NAME"
    done
    read SERVICE_ID_INPUT
    SERVICE_ID=$($PSQL "SELECT service_id FROM services WHERE service_id = $SERVICE_ID_INPUT;")
    if [[ -z $SERVICE_ID ]]
    then 
      MAIN_MENU "I could not find that service. What would you like today?"
    else
      GET_USER
    fi
  fi
}

GET_USER () {
    echo -e "\nWhat's your phone number?"
    read PHONE_NUMBER

    CUSTOMER_ID=$($PSQL "SELECT customer_id FROM customers WHERE phone = '$PHONE_NUMBER';")
    if [[ -z $CUSTOMER_ID ]]
    then
      echo -e "\nI don't have a record for that phone number, what's your name?"
      read CUSTOMER_NAME

      INSERT_CUSTOMER_RESULT=$($PSQL "INSERT INTO customers(phone, name) VALUES ('$PHONE_NUMBER','$CUSTOMER_NAME');")
      if [[ INSERT_CUSTOMER_RESULT != "INSERT 0 1" ]]
      then 
        echo "Error adding customer"
      fi
      CUSTOMER_ID=$($PSQL "SELECT customer_id FROM customers WHERE phone = '$PHONE_NUMBER';")
    fi
    CUSTOMER_NAME=$($PSQL "SELECT name FROM customers WHERE customer_id = CUSTOMER_ID;")
    MAKE_RESERVATION
}

MAKE_RESERVATION() {
  SERVICE_NAME=$($PSQL "SELECT name FROM services WHERE service_id = $SERVICE_ID;")
  echo -e "\nWhat time would you like your $SERVICE_NAME, $CUSTOMER_NAME?"
  read TIME_INPUT

  INSERT_APPOINTMENT_RESULT="$($PSQL "INSERT INTO appointments(customer_id, service_id, time) VALUES ($CUSTOMER_ID,$SERVICE_ID,'$TIME_INPUT');")"
  if [[ $INSERT_APPOINTMENT_RESULT = "INSERT 0 1" ]]
  then
    echo -e "\nI have put you down for a $SERVICE_NAME at $TIME_INPUT, $CUSTOMER_NAME."
  fi
}



MAIN_MENU 
