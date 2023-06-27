#! /bin/bash

PSQL="psql --username=freecodecamp --dbname=salon --tuples-only -c"

echo -e "\n~~~~~ MY SALON ~~~~~\n"

MAIN_MENU () {
if [[ -z $1 ]]
then
  echo -e "Welcome to My Salon, how can I help you?"
else
  echo -e "$1"
fi
SERVICES=$($PSQL "SELECT service_id, name FROM services")
echo "$SERVICES" | while read SERVICE_ID BAR SERVICE_NAME
do
  echo -e "$SERVICE_ID) $SERVICE_NAME"
done
}
MAIN_MENU 

read SERVICE_ID_SELECTED
SERVICE=$($PSQL "SELECT name FROM services WHERE service_id=$SERVICE_ID_SELECTED")
SERVICE_NAME="$(echo $SERVICE | sed -E 's/^ *| *$//g')"

if [[ -z $SERVICE_NAME ]]
then
  MAIN_MENU "That service does not exist, Select anything else?"
else
  echo -e "What is your phone number?"
  read CUSTOMER_PHONE
  CUSTOMER=$($PSQL "SELECT customer_id FROM customers WHERE phone='$CUSTOMER_PHONE'")
  if [[ -z $CUSTOMER ]]
  then
    echo -e "What is you name?"
    read CUSTOMER_NAME
    INSERT_CUSTOMER_RESULT=$($PSQL "INSERT INTO customers(name, phone) VALUES('$CUSTOMER_NAME', '$CUSTOMER_PHONE')")
  fi
  CUSTOMER_ID=$($PSQL "SELECT customer_id FROM customers WHERE phone='$CUSTOMER_PHONE'")
  NAME=$($PSQL "SELECT name FROM customers WHERE phone='$CUSTOMER_PHONE'")
  SELECTED_CUSTOMER_NAME="$(echo $NAME | sed -E 's/^ *| *$//g')"
  echo -e "What time do you want to schedule your appointment?"
  read SERVICE_TIME

  INSERT_APPOINTMENT_RESULT=$($PSQL "INSERT INTO appointments(customer_id, service_id, time) VALUES('$CUSTOMER_ID', '$SERVICE_ID_SELECTED', '$SERVICE_TIME')")
  echo "I have put you down for a $SERVICE_NAME at $SERVICE_TIME, $SELECTED_CUSTOMER_NAME."
fi
