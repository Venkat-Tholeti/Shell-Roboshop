#!/bin/bash

source ./Common.sh
app_name=redis

check_root

dnf module disable redis -y &>>$LOG_FILE
dnf module enable redis:7 -y &>>$LOG_FILE
dnf install redis -y &>>$LOG_FILE
VALIDATE $? "Redis Installation is"

sed -i -e 's/127.0.0.1/0.0.0.0/g' -e '/protected-mode/ c protected-mode no' /etc/redis/redis.conf
VALIDATE $? "Config Changes in redis"
#Here -e is expression

systemctl enable redis 
systemctl start redis 
VALIDATE $? "Enable & start redis service"

print_time