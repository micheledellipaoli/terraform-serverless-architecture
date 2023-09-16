# Table of contents
1. [Introduction to a Microservices architecture](#introduction)
    1. [User Interface](#user-interface)
    2. [APIs](#apis)
    3. [Microservices](#microservices)
    4. [Data Store](#data-store)
2. [Terraform configuration](#terraform-configuration)
3. [Infrastructure deployment](#deployment)
4. [Making requests to the APIs](#making-requests)

# 1 - Introduction to a Microservices Architecture <a name="introduction"></a>
A microservices architecture is made up of vertical layers: User Interface, APIs, Microservices and Data store.

## 1.1 - User Interface <a name="user-interface"></a>
It is usually a single-page application implemented by using JavaScript frameworks that communicates with RESTful APIs.\
For instance, you can execute AJAX requests to the RESTful APIs by using JQuery.

Any static web content can be served by using Amazon S3 and Amazon CloudFront.\
Amazon S3 is an Object Storage service that allows to store data as Objects within repositories named Buckets.\
Amazon CloudFront is a global CDN service which is built on top of  AWS Edge Locations.\
It helps in accelerating the delivery of any kind of content to the clients, such as: static web-pages, images, videos, APIs, etc.\
Since clients are served from the closest Edge Location, they get responses with low latency.

For our purposes, we do not use any User Interface, so we're going to make requests directly to our APIs by using a client such as: cURL, Powershell or Postman.  


## 1.2 - APIs <a name="apis"></a>
The APIs of a microservice are the central entry point for all the incoming client requests.\
In other words, the application logic hides behind a set of RESTful APIs.\

In general, API stands for "Application Programming Interface".\
An API represents the interface of a back-end component.
Each request to the back-end component is first routed to its relative API.
The API processes the request and might also implement some functionalities, such as: traffic management, routing, authentication, authorization.
Finally, the API routes the request to the proper back-end component for processing.

### 1.2.1 - Benefits of APIs
APIs allow different services to communicate with each other, without having to know how a service works in details.\
They allow to share data between services: it can be seen as a new paradigm named "Data as a Service".\
Moreover, they makes it easier to integrate new components into an existing architecture: this allows to speed up both the development and the deployment of new features, fostering the innovation.

### 1.2.2 - RESTful APIs
REST stands for (REpresentational State Transfer).
It is an architectural style for APIs: those that follow this style are called "RESTful".\
It is based on 6 principles.\
The most important are: Client-server architecture, stateless-ness, Hypermedia as engine of application state.\
This last principle is very important because it describes the interaction between the Client and the Server:\
• a Client requests the representation of a resource to the Server;\
• the Server returns the resource with links to other related resources;\
• the Client gets the resource but can also request one of the related resources by following the links provided in the first response;\
• the Server returns the resource with links to other related resources;\
This way, the Client gradually discovers new resources.

### 1.2.3 - Challenges of implementing APIs
Deploying, monitoring, maintaining APIs can be time-consuming.\
The main challenges are the following:\
• running different versions of APIs to ensure backward compatibility for all clients using previous versions;\
• providing access authorization;\
• throttling the requests in order to protect the back-end;\
• caching the responses in order to reduce the latency.

### 1.2.4 - Amazon API Gateway
Amazon API Gateway is a fully-managed service that helps in reducing the operational complexity of creating and maintaining HTTP and RESTful APIs.\
It acts as a front door to any back-end running either: on AWS (deployed on EC2, ECS, Lambda) or in any on-premise environment.\
It handles the API requests from any client and routes them to the proper back-end component.

By working with Amazon CloudFront, it's possible to provide a caching mechanism for GET requests.\
Suppose that a Client makes a GET request to the API Gateway.\
The API Gateway handles the request and routes it to the closest CloudFront Edge Location in order to serve the request while minimizing the latency;\
If the the request is in the cache, a cached response is returned to the Client.\
Otherwise, the API Gateway forwards the request to the back-end component for processing; once the back-end component has processed the request, the API Gateway returns a response to the Client.\
All other request methods (PUT, POST, DELETE) are automatically routed to the proper back-end components.

For our purposes, we do not use Amazon CloudFront for caching GET requests.


# 1.3 - Microservices <a name="microservices"></a>
To implement a Microservices application, a Cloud customer can use:\
• Amazon ECS with the support of Amazon ELB Application Load Balancer;\
• FaaS (Function as a Service) with AWS Lambda as the ultimate step to eliminate the operational complexity of managing servers.

In general, FaaS enables the Cloud customers to run small pieces of code without the need for setting-up and manage the servers on which the code is executed.\
However, this doesn't mean that FaaS doesn't require Servers.\
In this case, the Cloud provider is responsible for provisioning, deploying, managing and scaling the underlying infrastructure.\
This way, the Cloud customer is abstracted from these tasks and can focus on the application logic.

The small pieces of code we're referring to are also known as functions.\
Functions run on stateless ephimeral Containers created and managed by the Cloud provider.\
They are executed in response to events.\
Because of this, FaaS is ideal for Event-driven computation.

In resume, FaaS can be seen as an extension to the traditional Cloud Delivery Models (IaaS, PaaS, SaaS).\
With FaaS, the Cloud customer just needs to provide code, everything else is abstracted from its responsibility and is handled by the Cloud provider.


## 1.3.1 - AWS Lambda
As said before, AWS Lambda allows the Cloud customer to run code without worrying about the provisioning, deployment, management, scaling of the servers.\
It will automatically take care of all this.\
The main benefit is the billing: the Cloud customer pays only for the compute-time used and he won't be charged when the code is not running.

A Lambda function can be either triggered from other AWS services or can be called directly from any web or mobile app.\
AWS Lambda is integrated with Amazon API Gateway: it is possible to make invoke Lambda functions from the API Gateway in order to create a serverless application.


# 1.4 - Data Store <a name="data-store"></a>
The Data Store layer is used to store the data needed by the microservices.\
It can include an in-memory cache and a Database component.

## 1.4.1 - In-memory cache
A cache is ideal to store non-durable data, such as those stored in the session.\
Putting a cache between the Microservice layer and the Database allows to:\
• alleviate the read workload from the Database, which can focus on executing write operations;\
• improve access latency to data.

### 1.4.1.1 - Amazon ElastiCache
Amazon ElastiCache is a caching service.\
It improves the performance of the applications because it allows to retrieve data from fast in-memory caches, instead of using slower disk-based databases.\
It is compatible with two Caching engine: Memcached and Redis.

For our purposes, we are not going to use any In-memory cache service.


## 1.4.2 - Database
Databases can be either: Relational (SQL) or Non-Relational (NoSQL).

A Relational Database is ideal for structured data.\
It represents data into a well-defined schema that highlights the relationships between them.\
It provides limited scalability and performances.

A Non-Relational Database is ideal when data are not structured.\
It represents data in a schema-less way.\
It provides high scalability and high performances.

Since microservices are "specialized" to do one thing well, they have a simplified data-model that can be well suited for NoSQL Databases.


### 1.4.2.1 - Amazon DynamoDB
Amazon DynamoDB provides NoSQL Databases that support both document and key-value data models.\
It provides automatic scaling and single-digit millisecond latency.

A DynamoDB Table is a collection of items, each item is a collection of attributes, and each attribute is a key-value pair.\
It is schemaless: each item has its own attributes.\
It uses:\
• a Primary Key to identify each item;\
• Secondary Indexes to provide more flexible querying capabilities.


# 2 - Terraform configuration <a name="terraform-configuration"></a>
The main.tf Terraform configuration provided in this repository allows to deploy a microservices architecture on AWS.\
Such architecture consists of several AWS resources, including: a DynamoDB table, an API Gateway and two AWS Lambda functions.\
Let's have a look at the key components of the Terraform configuration.

## 2.1 - AWS Provider Configuration
This section specifies the AWS provider configuration, including the AWS region and authentication profile.
```
provider "aws" {
  profile = "default"
  region  = "eu-west-1"
}
```


## 2.2 - DynamoDB Table Creation
Here, we define a DynamoDB table named "ITEM" with specific attributes and global secondary indexes. This table will store the data for needed by our microservices.
```
resource "aws_dynamodb_table" "item_table" {
  # ...
}
```

## 2.3 - API Gateway Configuration
This resource sets up an API Gateway named "item_apigw" in order to provide a public interface for our microservices. 
```
resource "aws_api_gateway_rest_api" "item_apigw" {
  # ...
}
```

## 2.4 - Lambda Functions Creation
In this section, we define two AWS Lambda functions named "postItemHandler" and "getItemHandler" that are responsible for handling respectively POST and GET requests and interact with the DynamoDB table.
```
resource "aws_lambda_function" "postItemHandler" {
  # ...
}
```
```
resource "aws_lambda_function" "getItemHandler" {
  # ...
}
```
```
resource "aws_lambda_function" "putItemHandler" {
  # ...
}
```
```
resource "aws_lambda_function" "deleteItemHandler" {
  # ...
}
```

## 2.5 - API Gateway Integration
These following resources configure the integration of the API Gateway with the Lambda functions, allowing the incoming HTTP requests to trigger the Lambda functions.

```
resource "aws_api_gateway_integration" "postitem-lambda-api" {
  # ...
}
```
```
resource "aws_api_gateway_integration" "getitem-lambda-api" {
  # ...
}
```
```
resource "aws_api_gateway_integration" "putitem-lambda-api" {
  # ...
}
```
```
resource "aws_api_gateway_integration" "deleteitem-lambda-api" {
  # ...
}
```


## 2.6 - Lambda Permissions
These resources grant the permissions for the API Gateway service to invoke the Lambda functions.
```
resource "aws_lambda_permission" "apigw-postItemHandler" {
  # ...
}
```
```
resource "aws_lambda_permission" "apigw-getItemHandler" {
  # ...
}
```
```
resource "aws_lambda_permission" "apigw-putItemHandler" {
  # ...
}
```
```
resource "aws_lambda_permission" "apigw-deleteItemHandler" {
  # ...
}
```


## 2.7 - API Gateway Deployment
This resource deploys the API Gateway into a stage named "prod".
```
resource "aws_api_gateway_deployment" "item_api_stage_prod" {
  # ...
}
```


# 3 - Infrastructure deployment <a name="deployment"></a>
Clone this repository to your local machine.\
Then, navigate to the repository folder and initialize Terraform by executing the following command:

```
terraform init
```

Validate the configuration in order to check if there is any syntax error by executing the command:
```
terraform validate
```

Apply the configuration to create the AWS resources by executing the following command:
```
terraform apply -auto-approve
```

Now, jump to the paragraph 4 to test the APIs by making some POST and GET requests.\
After that, to destroy the AWS resources created by Terraform, execute:
```
terraform destroy -auto-approve
```



# 4 - Making requests to the APIs <a name="making-requests"></a>
Once you've deployed your infrastructure by using Terraform, you can make requests to the APIs by using a client such as: cURL, Powershell or Postman.

## 4.1 - Insert an Item
The following commands allow to insert an item into the DynamoDB table.\
Execute one of them depending on the client you're using.

Note: make sure to replace [API-Gateway-URL] with the URL of your Amazon API Gateway.

Command for cURL:
```
curl -X POST "[API-Gateway-URL]/prod/item" -H "Content-Type: application/json" -d "{\"item_id\":\"1\", \"item_name\":\"Birra Peroni\", \"item_category\":\"Bevande\", \"item_price\":2}"

```

Command for Powershell:
```
Invoke-RestMethod -Method Post -Uri "[API-Gateway-URL]/prod/item" -Headers @{"Content-Type"="application/json"} -Body '{"item_id":"1","item_name":"Birra Peroni","item_category":"Bevande","item_price":2}'

```

## 4.2 - Get the list of the Items
The following commands allow to retrieve the list of the items stored into the DynamoDB table.\
Execute one of them depending on the client you're using.

Note: make sure to replace [API-Gateway-URL] with the URL of your Amazon API Gateway.

Command for cURL:
```
curl -X GET "[API-Gateway-URL]/prod/item" -H "Content-Type: application/json"

```

Command for Powershell:
```
Invoke-RestMethod -Method Get -Uri "[API-Gateway-URL]/prod/item" -Headers @{"Content-Type"="application/json"}

```

## 4.3 - Insert another Item
The following commands allow to insert another item into the DynamoDB table.\
Execute one of them depending on the client you're using.

Note: make sure to replace [API-Gateway-URL] with the URL of your Amazon API Gateway.

Command for cURL:
```
curl -X POST "[API-Gateway-URL]/prod/item" -H "Content-Type: application/json" -d "{\"item_id\":\"2\", \"item_name\":\"Birra Heineken\", \"item_category\":\"Bevande\", \"item_price\":3}"

```

Command for Powershell:
```
Invoke-RestMethod -Method Post -Uri "[API-Gateway-URL]/prod/item" -Headers @{"Content-Type"="application/json"} -Body '{"item_id":"2","item_name":"Birra Heineken","item_category":"Bevande","item_price":3}'

```

## 4.4 - Get an Item by ID
The following commands allow to retrieve an item by ID.\
Execute one of them depending on the client you're using.

Note: make sure to replace [API-Gateway-URL] with the URL of your Amazon API Gateway and [VALUE] with the ID of one of the Items you've inserted before. 

Command for cURL:
```
curl -X GET "[API-Gateway-URL]/prod/item?item_id=[VALUE]" -H "Content-Type: application/json"

```

Command for Powershell:
```
Invoke-RestMethod -Method Get -Uri "[API-Gateway-URL]/prod/item?item_id=[VALUE]" -Headers @{"Content-Type"="application/json"}

```


## 4.5 - Update an existing Item
The following commands allow to update an existing item in the DynamoDB table.\
Execute one of them depending on the client you're using.

Note: make sure to replace [API-Gateway-URL] with the URL of your Amazon API Gateway.

Command for cURL:
```
curl -X POST "[API-Gateway-URL]/prod/item" -H "Content-Type: application/json" -d "{\"item_id\":\"1\", \"item_name\":\"Birra Peroni\", \"item_category\":\"Bevande\", \"item_price\":2.5}"

```

Command for Powershell:
```
Invoke-RestMethod -Method Post -Uri "[API-Gateway-URL]/prod/item" -Headers @{"Content-Type"="application/json"} -Body '{"item_id":"1","item_name":"Birra Peroni","item_category":"Bevande","item_price":2.5}'

```


## 4.6 - Delete an Item
The following commands allow to delete an item by passing the ID in the request.\
Execute one of them depending on the client you're using.

Note: make sure to replace [API-Gateway-URL] with the URL of your Amazon API Gateway and [VALUE] with the ID of one of the Items you've inserted before. 

Command for cURL:
```
curl -X DELETE "[API-Gateway-URL]/prod/item?item_id=[VALUE]" -H "Content-Type: application/json"

```

Command for Powershell:
```
Invoke-RestMethod -Method Delete -Uri "[API-Gateway-URL]/prod/item?item_id=[VALUE]" -Headers @{"Content-Type"="application/json"}

```

Invoke-RestMethod -Method Post -Uri "https://rojnenwf9i.execute-api.eu-west-1.amazonaws.com/prod/item" -Headers @{"Content-Type"="application/json"} -Body '{"item_id":"2","item_name":"Birra Heineken","item_category":"Bevande","item_price":3}'

Invoke-RestMethod -Method Get -Uri "https://rojnenwf9i.execute-api.eu-west-1.amazonaws.com/prod/item" -Headers @{"Content-Type"="application/json"}

Invoke-RestMethod -Method Put -Uri "https://rojnenwf9i.execute-api.eu-west-1.amazonaws.com/prod/item" -Headers @{"Content-Type"="application/json"} -Body '{"item_id":"2","item_name":"Birra Peroni","item_category":"Bevande","item_price":4}'

Invoke-RestMethod -Method Delete -Uri "https://rojnenwf9i.execute-api.eu-west-1.amazonaws.com/prod/item?item_id=2" -Headers @{"Content-Type"="application/json"}