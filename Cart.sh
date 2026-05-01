#!/bin/bash

START_TIME=$(date +%s)
USERID=$(id -u)
R="\e[31m"
G="\e[32m"
Y="\e[33m"
N="\e[0m"
LOGS_FOLDER="/var/log/roboshop-logs"
SCRIPT_NAME=$(echo $0 | cut -d "." -f1)
LOG_FILE="$LOGS_FOLDER/$SCRIPT_NAME.log"
SCRIPT_DIRECTORY=$PWD


mkdir -p $LOGS_FOLDER

echo -e "$G Script Started Executing At $(date) $N" | tee -a $LOG_FILE

if [ $USERID -ne 0 ]
then  
  echo -e  "$R ERROR: Please run this script with root access $N" | tee -a $LOG_FILE
  exit 1 # we can give any number upto 127 other than 0 
else
  echo -e  "$G You are Running with root access $N" | tee -a $LOG_FILE
fi

#FUNCTION FOR REPEATED CODE
VALIDATE(){
    if [ $1 -eq 0 ] # We can pass arguments to function also , Here $1 is 1st argument ($?) of VALIDATE in Installed space below
  then
    echo -e   "$G  $2 is success $N" | tee -a $LOG_FILE # $2 is Software mentioned as below in VALIDATE function in INSTALLED SPACE BELOW
  else
    echo -e  "$R  $2 is failure $N" | tee -a $LOG_FILE
    exit 1
  fi

}

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

curl -o /tmp/user.zip https://roboshop-artifacts.s3.amazonaws.com/user-v3.zip &>>$LOG_FILE
rm -rf /app/*
cd /app 
unzip /tmp/user.zip &>>$LOG_FILE
VALIDATE $? "Downloading the application code to created app directory"

cd /app 
npm install &>>$LOG_FILE
VALIDATE $? "Downloading the dependencies"

#HERE WE WILL BE IN APP DIRECTORY FROM ABOVE COMMAND, but our service is in our home directory, so we have written SCRIPT directory in the starting and gave $PWD and stored that value
cp $SCRIPT_DIRECTORY/user.service /etc/systemd/system/user.service
VALIDATE $? "Copying Of user services"

systemctl daemon-reload
systemctl enable user 
systemctl start user
VALIDATE $? "Daemon Reload, Enable & Starting of User"

END_TIME=$(date +%s)
TOTAL_TIME=$(( $END_TIME - $START_TIME ))

echo -e "Script execution completed successfully, $Y time taken: $TOTAL_TIME seconds $N" | tee -a $LOG_FILE
