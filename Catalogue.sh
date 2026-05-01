#!/bin/bash

source ./Common.sh
app_name=catalogue

NodeJs_Setup

Roboshop_User

app_setup

Services_Status

cp $SCRIPT_DIRECTORY/mongodb.repo /etc/yum.repos.d/mongo.repo
VALIDATE $? "Copying MongoDb Repo" 

dnf install mongodb-mongosh -y &>>$LOG_FILE
VALIDATE $? "Installing Mongodb Client"

STATUS=$(mongosh --host mongodb.daws84s.site --eval 'db.getMongo().getDBNames().indexOf("catalogue")')
if [ $STATUS -lt 0 ]
then
    mongosh --host mongodb.devopsaws.store </app/db/master-data.js &>>$LOG_FILE
    VALIDATE $? "Loading data into MongoDB"
else
    echo -e "Data is already loaded ... $Y SKIPPING $N"
fi

mongosh --host mongodb.devopsaws.store </app/db/master-data.js
VALIDATE $? "Load Master Data of the List of products"

print_time

