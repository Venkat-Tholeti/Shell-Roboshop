#!/bin/bash

source ./Common.sh
app_name=shipping

check_root

echo "Please Enter Root password OF MYSQL"
read -s MYSQL_ROOT_PASSWORD 

dnf install maven -y &>>$LOG_FILE
VALIDATE $? "Installing Maven"

Roboshop_User

app_setup

cd /app 
mvn clean package &>>$LOG_FILE
mv target/shipping-1.0.jar shipping.jar  &>>$LOG_FILE
VALIDATE $? "Downloading the dependencies"


Services_Status

dnf install mysql -y &>>$LOG_FILE
VALIDATE $? "Mysql Client Installation"

mysql -h mysql.devopsaws.store -u root -p$MYSQL_ROOT_PASSWORD -e 'use cities' &>>$LOG_FILE
if [ $? -ne 0 ]
then
    mysql -h mysql.devopsaws.store -uroot -p$MYSQL_ROOT_PASSWORD < /app/db/schema.sql &>>$LOG_FILE
    mysql -h mysql.devopsaws.store -uroot -p$MYSQL_ROOT_PASSWORD < /app/db/app-user.sql  &>>$LOG_FILE
    mysql -h mysql.devopsaws.store -uroot -p$MYSQL_ROOT_PASSWORD < /app/db/master-data.sql &>>$LOG_FILE
    VALIDATE $? "Loading data into MySQL"
else
    echo -e "Data is already loaded into MySQL ... $Y SKIPPING $N"
fi


systemctl restart shipping
VALIDATE $? "Restart Shipping"

print_time