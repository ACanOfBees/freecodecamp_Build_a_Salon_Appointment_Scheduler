#!/bin/bash

echo -e "\n~~~ Salon Appointment Scheduler ~~~\n"

PSQL="psql --username=freecodecamp --dbname=salon --tuples-only -c "

MAIN_MENU() {
  if [[ $1 ]]
  then 
    echo -e "\n$1"
  else
    echo -e "Pick a service you would like an appointment for.\n"
  fi
  # fetch service ids
  SERVICES=$($PSQL "select * from services order by service_id")
  if [[ $SERVICES ]]
  then
    # display service ids
    echo "$SERVICES" | while read SERVICE_ID BAR NAME
    do 
      echo "$SERVICE_ID) $NAME"
    done
    # read service
    read SERVICE_ID_SELECTED
    if [[ $SERVICE_ID_SELECTED =~ ^[0-9]+$ ]]
    then
      # fetch service
      SERVICE_EXISTS=$($PSQL "select count(*) from services where service_id='$SERVICE_ID_SELECTED'")
      if [[ $SERVICE_EXISTS =~ 1 ]]
      then
        PROCESS_APPOINTMENT $SERVICE_ID_SELECTED
      fi
    else 
      MAIN_MENU "Service not found. Please pick one of the listed services below."
    fi
  fi
}

PROCESS_APPOINTMENT(){
  SERVICE_ID_SELECTED=$1
  # read phone number
  echo "Enter your phone number:"
  read CUSTOMER_PHONE
  # check if customer exists
  CUSTOMER_ID=$($PSQL "select customer_id from customers where phone='$CUSTOMER_PHONE'")
  # if customer doesn't exist
  if [[ -z $CUSTOMER_ID ]]
  then
    # read name
    echo "Enter your name:"
    read CUSTOMER_NAME
    # insert customer
    INSERT_CUSTOMER=$($PSQL "insert into customers(phone, name) values('$CUSTOMER_PHONE', '$CUSTOMER_NAME')")
    # get new customer_id
    CUSTOMER_ID=$($PSQL "select customer_id from customers where phone='$CUSTOMER_PHONE'")
  else 
    CUSTOMER_NAME=$($PSQL "select name from customers where phone='$CUSTOMER_PHONE'")
  fi
  # read Time of appointment
  echo "What time would you like to have your appointment:"
  read SERVICE_TIME
  INSERT_APPOINTMENT=$($PSQL "insert into appointments(customer_id, service_id, time) values($CUSTOMER_ID, $SERVICE_ID_SELECTED, '$SERVICE_TIME')")
  if [[ $INSERT_APPOINTMENT == 'INSERT 0 1' ]]
  then 
    SERVICE=$($PSQL "select name from services where service_id='$SERVICE_ID_SELECTED'")
    echo "I have put you down for a $(echo $SERVICE | sed -r 's/^ *| *$//g') at $SERVICE_TIME, $CUSTOMER_NAME."
  fi
}

MAIN_MENU
