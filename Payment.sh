#!/bin/bash

source ./Common.sh
app_name=payment

check_root

dnf install python3 gcc python3-devel -y &>>$LOG_FILE
VALIDATE $? "Installing Python"

Roboshop_User

app_setup

cd /app 
pip3 install -r requirements.txt &>>$LOG_FILE
VALIDATE $? "Downloading the dependencies"


Services_Status


print_time
