# 🚀 Project Title - Cloud-Enabled Three-Tier Web Application Deployment with Azure

## Overview

My project aims to deploy a highly available and scalable three-tier web application on Microsoft Azure, leveraging the cloud's powerful services and features. The architecture comprises a frontend, backend, and database tier, each hosted on separate subnets for improved security and isolation.

This project showcases the power of Azure's infrastructure as a service (IaaS) and platform as a service (PaaS) offerings to deploy a robust and reliable three-tier web application architecture. By utilizing Azure's load balancers, VMSS, managed databases, and security features, we ensure our application is highly available, scalable, and secure, providing an excellent user experience while minimizing operational overhead.

## 🏠 Architecture
![Architecture of the application](architecture.png)

## Web Application Tech stack

- React 
- Nodejs
- MySQL

## 🖥️ Installation of frontend

**Note**: You should have Nodejs installed on your system. [Node.js](https://nodejs.org/)

👉 Let's install dependency to run react application

```sh
cd client
npm install
```

**Note**: you have to change one file for the backend API. you will find that `src/pages/config.js`

```sh
vim src/pages/config.js
```

```javascript
// const API_BASE_URL = "http://25.41.26.237:80"; // on live backend server which is running on port 80
const API_BASE_URL = "http://localhost:portNumber";
export default API_BASE_URL;
```
make sure you EDIT the above file depending on your scenario


```sh
npm run build 
```

above command create optimize build of the application in the client folder. `build/` you will find all the files that you can serve through **Apache** or **Nginx**
that's the whole setup of the frontend

##  🖥️ ️Installation of backend

**Note**: You should have nodejs installed on your system. [Node.js](https://nodejs.org/)

👉 let install dependency to run Nodejs  API

```sh
cd backend
npm install
```
Now we need to create a .env file that holds all the configuration details of the backend. you should be in the backend directory

```sh
vim .env
```
add below content 

```javascript
DB_HOST=localhost or URL_of_Azure_Database
DB_USERNAME=user_name_of_MySQL
DB_PASSWORD=passwod_of_my_sql
PORT=3306
```
**Note**: please change the above file depending on your setup. You may use Azure Databases for MySql or a Local MySql server on your system. your MySQL contains a database with the name of `test` and should have a `books` table. You can use test.sql to create a table 


```sh
mysql -h <<RDS_ENDPOINT OR localhost>> -u <<USER_NAME>> -p<<PASSWORD>>

CREATE DATABASE test;

mysql -h <<RDS_ENDPOINT OR localhost>> -u <<USER_NAME>> -p<<PASSWORD>> test < test.sql
```


Install pm2 if you want to run on the cloud. you may need sudo privileges to install it because we are going to install it globally.

```sh
npm install -g pm2
```

Now you can run this application. Make sure you are in the backend directory


```sh
pm2 start index.js --name "backendAPI"
```

The above command will start the node server on port 80, you can modify the port number in the `index.js` file

✈️ Now we are Ready to see the application

**Thank you so much for reading..😅**
