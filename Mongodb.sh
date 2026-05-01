#!/bin/bash

source ./Common.sh
app_name=mongodb

check_root

cp mongodb.repo /etc/yum.repos.d/mongdb.repo 
VALIDATE $? "Copying MongoDb Repo"

dnf install mongodb-org -y  &>>$LOG_FILE
VALIDATE $? "Installing MongoDb"

systemctl enable mongod &>>$LOG_FILE
systemctl start mongod  &>>$LOG_FILE
VALIDATE $? "Enabling & Starting mongod"

sed -i 's/127.0.0.1/0.0.0.0/g' /etc/mongod.conf
VALIDATE $? "Config Changes"

systemctl restart mongod &>>$LOG_FILE
VALIDATE $? "Restart Mongod after config changes"

print_time