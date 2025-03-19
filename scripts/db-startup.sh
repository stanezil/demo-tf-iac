#!/bin/bash

# Update the system
yum update -y

# Install MongoDB
echo "[mongodb-org-4.4]
name=MongoDB Repository
baseurl=https://repo.mongodb.org/yum/amazon/2/mongodb-org/4.4/x86_64/
gpgcheck=1
enabled=1
gpgkey=https://www.mongodb.org/static/pgp/server-4.4.asc" | tee /etc/yum.repos.d/mongodb-org-4.4.repo

yum install -y mongodb-org
systemctl start mongod
systemctl enable mongod

# Wait for MongoDB to start
sleep 10

# Install Python and PIP
yum install -y python3 python3-pip

# Python script to generate and insert fake emails
echo "import pymongo
from faker import Faker
import random

fake = Faker()

# Connect to MongoDB
client = pymongo.MongoClient('localhost', 27017)
db = client.fake_emails
collection = db.emails

# Generate and insert emails
for _ in range(1000):
    email = fake.email()
    document = {'email': email}
    collection.insert_one(document)

print('1000 fake emails inserted into MongoDB.')" > insert_emails.py

# Install Python dependencies and run the script
pip3 install pymongo Faker
python3 insert_emails.py