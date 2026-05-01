#!/bin/bash

source ./Common.sh
app_name=Catalogue

dnf module disable nodejs -y &>>$LOG_FILE
VALIDATE $? "Disabling Nodejs"

dnf module enable nodejs:20 -y &>>$LOG_FILE
VALIDATE $? "Nodejs Enable"

dnf install nodejs -y &>>$LOG_FILE
VALIDATE $? "Installing NodeJs"

id roboshop
if [ $? -ne 0 ]
then
    useradd --system --home /app --shell /sbin/nologin --comment "roboshop system user" roboshop
    VALIDATE $? "Adding Roboshop User"
else
    echo -e "System User Roboshop Exists  $Y SKIPPING $N"
fi

mkdir -p /app 
VALIDATE $? "Creating APP Directory"

curl -o /tmp/catalogue.zip https://roboshop-artifacts.s3.amazonaws.com/catalogue-v3.zip &>>$LOG_FILE
rm -rf /app/*
cd /app 
unzip /tmp/catalogue.zip &>>$LOG_FILE
VALIDATE $? "Downloading the application code to created app directory"

cd /app 
npm install &>>$LOG_FILE
VALIDATE $? "Downloading the dependencies"

#HERE WE WILL BE IN APP DIRECTORY FROM ABOVE COMMAND, but our service is in our home directory, so we have written SCRIPT directory in the starting and gave $PWD and stored that value
cp $SCRIPT_DIRECTORY/catalogue.service /etc/systemd/system/catalogue.service
VALIDATE $? "Copying Of catalogue services"

systemctl daemon-reload
systemctl enable catalogue 
systemctl start catalogue
VALIDATE $? "Daemon Reload, Enable & Starting of Catalogue"

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

