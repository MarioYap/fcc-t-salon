#!/bin/bash
PSQL="psql --username=freecodecamp --dbname=salon --tuples-only -c"

MAIN_MENU() {
  if [[ $1 ]]
  then
    echo -e "\n$1"
  fi

  echo -e "\n~~~ Salon Menu ~~~\n"
  echo "Choose Service:"
  SERVICES=$($PSQL "SELECT * FROM services ORDER BY service_id")

  echo "$SERVICES" | while read SERVICE_ID BAR SERVICE_NAME
  do
    echo "$SERVICE_ID) $SERVICE_NAME"
  done
  echo "0) Exit" 

  read SERVICE_ID_SELECTED
  if [[ $SERVICE_ID_SELECTED == 0 ]]
  then
    echo -e "\n~~~ Have a nice day ~~~"
  else
    SERVICE_ID=$($PSQL "SELECT service_id FROM services WHERE service_id = $SERVICE_ID_SELECTED")
    APPOINTMENT_MENU "$SERVICE_ID"
  fi
}

APPOINTMENT_MENU() {
  if [[ -z $1 ]]
  then
    MAIN_MENU "Please select available option"
  else
    echo -e "\nEnter phone number:"
    read CUSTOMER_PHONE
    PHONE_RECORD=$($PSQL "SELECT phone FROM customers WHERE phone = '$CUSTOMER_PHONE'")

    if [[ -z $PHONE_RECORD ]]
    then
      echo -e "\nEnter your name:"
      read CUSTOMER_NAME
      NEW_CUSTOMER=$($PSQL "INSERT INTO customers(phone, name) VALUES('$CUSTOMER_PHONE', '$CUSTOMER_NAME')")
    fi

    CUSTOMER_ID=$($PSQL "SELECT customer_id FROM customers WHERE phone = '$CUSTOMER_PHONE'")

    echo -e "\nSelect appointment time:"
    read SERVICE_TIME
    INSERT_APPOINTMENT=$($PSQL "INSERT INTO appointments(customer_id, service_id, time) VALUES ($CUSTOMER_ID, $1, '$SERVICE_TIME')")

    SERVICES=$($PSQL "SELECT name FROM services WHERE service_id = $1")
    CUSTOMER_NAME=$($PSQL "SELECT name FROM customers WHERE phone = '$CUSTOMER_PHONE'")
    echo -e "\nI have put you down for a $(echo $SERVICES | sed -E 's/^ *| *$//g') at $(echo $SERVICE_TIME | sed -E 's/^ *| *$//g'), $(echo $CUSTOMER_NAME | sed -E 's/^ *| *$//g')."

  fi
}

MAIN_MENU
