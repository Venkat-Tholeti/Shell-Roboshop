#!/bin/bash

source ./Common.sh
app_name=mysql

echo "Please Enter Root password OF MYSQL"
read -s MYSQL_ROOT_PASSWORD 

dnf install mysql-server -y &>>$LOG_FILE
VALIDATE $? "Installation of MySQL server"

systemctl enable mysqld
systemctl start mysqld 
VALIDATE $? "Enable & Start of MySQL server"

mysql_secure_installation --set-root-pass $MYSQL_ROOT_PASSWORD

print_time