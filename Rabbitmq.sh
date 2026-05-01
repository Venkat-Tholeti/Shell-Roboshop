#!/bin/bash

source ./Common.sh
app_name=rabbitmq

check_root

echo "Please Enter Password for RabbitMq"
read -s RabbitMq_PASSWORD 

cp rabbitmq.repo /etc/yum.repos.d/rabbitmq.repo
VALIDATE $? "Rabbitmq Repo Copy"

dnf install rabbitmq-server -y &>>$LOG_FILE
VALIDATE $? "Installation Of Rabbitmq"

systemctl enable rabbitmq-server
systemctl start rabbitmq-server
VALIDATE $? "Enable & Starting of Rabbitmq service"

id roboshop
if [ $? -ne 0 ]
then
    rabbitmqctl add_user roboshop $RabbitMq_PASSWORD
    rabbitmqctl set_permissions -p / roboshop ".*" ".*" ".*"
    VALIDATE $? "Adding Roboshop User"
else
    echo -e "System User Roboshop Exists  $Y SKIPPING $N"
fi

print_time
