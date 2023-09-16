# Dichiarazione del provider AWS
provider "aws" {
  profile = "default"
  region  = "eu-west-1"
}

# Dichiarazione del provider archive: utile a creare un file .zip in maniera dinamica, ogni volta che delle modifiche vengono apportate al file sorgente.
provider "archive" {}

# Creazione di una tabella DynamoDB denominata "ITEM"
resource "aws_dynamodb_table" "item_table" {
  name         = "ITEM"
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "item_id"

  attribute {
    name = "item_id"
    type = "S"
  }

  attribute {
    name = "item_name"
    type = "S"
  }

  attribute {
    name = "item_category"
    type = "S"
  }

  attribute {
    name = "item_price"
    type = "N"
  }

  # Indicizzazione dell'attributo "item_name" come indice globale
  global_secondary_index {
    name = "item_name_index"
    hash_key = "item_name"
    projection_type = "ALL"
  }

   # Indicizzazione dell'attributo "item_category" come indice globale
  global_secondary_index {
    name = "item_category_index"
    hash_key = "item_category"
    projection_type = "ALL"
  }

   # Indicizzazione dell'attributo "item_price" come indice globale
  global_secondary_index {
    name = "item_price_index"
    hash_key = "item_price"
    projection_type = "ALL"
  }

}

# Creazione di una risorsa API Gateway denominata "item_apigw"
resource "aws_api_gateway_rest_api" "item_apigw" {
  name        = "item_apigw"
  description = "Item API Gateway"
  endpoint_configuration {
    types = ["REGIONAL"]
  }
}

# Creazione del path "/item" relativo all'API Gateway creato precedentemente
resource "aws_api_gateway_resource" "item" {
  rest_api_id = aws_api_gateway_rest_api.item_apigw.id
  parent_id   = aws_api_gateway_rest_api.item_apigw.root_resource_id
  path_part   = "item"
}


# Creazione del metodo "postitem" per il path /item
resource "aws_api_gateway_method" "postitem" {
  rest_api_id   = aws_api_gateway_rest_api.item_apigw.id
  resource_id   = aws_api_gateway_resource.item.id
  http_method   = "POST"
  authorization = "NONE"
}

# Creazione del metodo "getitem" per il path /item
resource "aws_api_gateway_method" "getitem" {
  rest_api_id   = aws_api_gateway_rest_api.item_apigw.id
  resource_id   = aws_api_gateway_resource.item.id
  http_method   = "GET"
  authorization = "NONE"
}

# Creazione del metodo "deleteitem" per il path /item
resource "aws_api_gateway_method" "putitem" {
  rest_api_id   = aws_api_gateway_rest_api.item_apigw.id
  resource_id   = aws_api_gateway_resource.item.id
  http_method   = "PUT"
  authorization = "NONE"
}

# Creazione del metodo "deleteitem" per il path /item
resource "aws_api_gateway_method" "deleteitem" {
  rest_api_id   = aws_api_gateway_rest_api.item_apigw.id
  resource_id   = aws_api_gateway_resource.item.id
  http_method   = "DELETE"
  authorization = "NONE"
}

# Creeremo 3 funzioni Lambda: 
#   getItemHandler: per ottenere la lista di tutti gli Items nella tabella (se il parametro item_id nella query string della richiesta non è presente) oppure per ottenere un Item ricercandolo per ID (se il parametro item_id nella query string della richiesta è presente);
#   postItemHandler: per inserire un Item nella tabella;
#   putItemHandler: per modificare un Item nella tabella;
#   deleteItemHandler: per eliminare un Item dalla tabella;
# Tuttavia, in AWS, le azioni che è possibile effettuare su una risorsa vengono autorizzate oppure limitate da Policy e Ruoli AWS.
# Pertanto, per garantire le funzioni Lambda possano effettuare operazioni di lettura e scrittura sulla tabella DynamoDB, è necessario creare un Ruolo ed una Policy IAM da associare a ciascuna funzione Lambda. 


# Di seguito, saranno create le seguenti risorse:
#   un Ruolo IAM chiamato "postItemLambdaRole": sarà assegnato alla funzione Lambda postItemHandler;
#   una Policy IAM chiamata "postItemLambdaPolicy": consentirà alla funzione Lambda di effettuare l'operazione PutItem sulla tabella DynamoDB denominata ITEM creata;
#   un'associazione Ruolo-Policy chiamata "postItemLambdaRolePolicy": consente di assegnare la Policy "postItemLambdaPolicy" al Ruolo "postItemLambdaRole"
resource "aws_iam_role" "postItemLambdaRole" {
  name               = "postItemLambdaRole"
  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "lambda.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF
}

data "template_file" "postitemlambdapolicy" {
  template = "${file("${path.module}/policies/postItemPolicy.json")}"
}

resource "aws_iam_policy" "postItemLambdaPolicy" {
  name        = "postItemLambdaPolicy"
  path        = "/"
  description = "IAM policy for the postItem Lambda function"
  policy      = data.template_file.postitemlambdapolicy.rendered
}

resource "aws_iam_role_policy_attachment" "postItemLambdaRolePolicy" {
  role       = aws_iam_role.postItemLambdaRole.name
  policy_arn = aws_iam_policy.postItemLambdaPolicy.arn
}

# Di seguito, saranno create le seguenti risorse:
#   un Ruolo IAM chiamato "getItemLambdaRole": sarà assegnato alla funzione Lambda getItemHandler;
#   una Policy IAM chiamata "getItemLambdaPolicy": consentirà alla funzione Lambda di effettuare le operazioni GetItem, Scan e Query  sulla tabella DynamoDB denominata ITEM creata;
#   un'associazione Ruolo-Policy chiamata "getItemLambdaRolePolicy": consente di assegnare la Policy "getItemLambdaPolicy" al Ruolo "getItemLambdaRole"
resource "aws_iam_role" "getItemLambdaRole" {
  name               = "getItemLambdaRole"
  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "lambda.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF
}

data "template_file" "getitemlambdapolicy" {
  template = "${file("${path.module}/policies/getItemPolicy.json")}"
}

resource "aws_iam_policy" "getItemLambdaPolicy" {
  name        = "getItemLambdaPolicy"
  path        = "/"
  description = "IAM policy for the getItem Lambda function"
  policy      = data.template_file.getitemlambdapolicy.rendered
}

resource "aws_iam_role_policy_attachment" "getItemLambdaRolePolicy" {
  role       = aws_iam_role.getItemLambdaRole.name
  policy_arn = aws_iam_policy.getItemLambdaPolicy.arn
}


# Di seguito, saranno create le seguenti risorse:
#   un Ruolo IAM chiamato "putItemLambdaRole": sarà assegnato alla funzione Lambda putItemHandler;
#   una Policy IAM chiamata "putItemLambdaPolicy": consentirà alla funzione Lambda di effettuare le operazioni GetItem e PutItem sulla tabella DynamoDB denominata ITEM creata;
#   un'associazione Ruolo-Policy chiamata "putItemLambdaRolePolicy": consente di assegnare la Policy "putItemLambdaPolicy" al Ruolo "putItemLambdaRole"
resource "aws_iam_role" "putItemLambdaRole" {
  name               = "putItemLambdaRole"
  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "lambda.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF
}

data "template_file" "putitemlambdapolicy" {
  template = "${file("${path.module}/policies/putItemPolicy.json")}"
}

resource "aws_iam_policy" "putItemLambdaPolicy" {
  name        = "putItemLambdaPolicy"
  path        = "/"
  description = "IAM policy for the putItem Lambda function"
  policy      = data.template_file.putitemlambdapolicy.rendered
}

resource "aws_iam_role_policy_attachment" "putItemLambdaRolePolicy" {
  role       = aws_iam_role.putItemLambdaRole.name
  policy_arn = aws_iam_policy.putItemLambdaPolicy.arn
}


# Di seguito, saranno create le seguenti risorse:
#   un Ruolo IAM chiamato "deleteItemLambdaRole": sarà assegnato alla funzione Lambda deleteItemHandler;
#   una Policy IAM chiamata "deleteItemLambdaPolicy": consentirà alla funzione Lambda di effettuare l'operazione DeleteItem sulla tabella DynamoDB denominata ITEM creata;
#   un'associazione Ruolo-Policy chiamata "deleteItemLambdaRolePolicy": consente di assegnare la Policy "deleteItemLambdaPolicy" al Ruolo "deleteItemLambdaRole".
resource "aws_iam_role" "deleteItemLambdaRole" {
  name               = "deleteItemLambdaRole"
  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "lambda.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF
}

data "template_file" "deleteitemlambdapolicy" {
  template = "${file("${path.module}/policies/deleteItemPolicy.json")}"
}

resource "aws_iam_policy" "deleteItemLambdaPolicy" {
  name        = "deleteItemLambdaPolicy"
  path        = "/"
  description = "IAM policy for the deleteItem Lambda function"
  policy      = data.template_file.deleteitemlambdapolicy.rendered
}

resource "aws_iam_role_policy_attachment" "deleteItemLambdaRolePolicy" {
  role       = aws_iam_role.deleteItemLambdaRole.name
  policy_arn = aws_iam_policy.deleteItemLambdaPolicy.arn
}



# Di seguito, vengono definite le risorse per la creazione delle due funzioni Lambda postItemHandler e getItemHandler.
# Il codice sorgente per le funzioni Lambda si trova nei file zip posizionati nella cartella "./lambda".
# Per ciascuna funzione Lambda, definiremo diversi attributi, tra cui il filename, il function_name e l'handler:  ad esempio, se il filename è "postItem.py" e l'handler all'interno della funzione è chiamato "lamnda_handler", allora definiamo per l'attributo handler il valore "postItem.lambda_handler".
# Inoltre, specificheremo due variabili d'ambiente per ciascuna funzione Lambda:
#   REGION: rappresenta la Region AWS in cui si vuole creare la funzione Lambda;
#   PRODUCT_TABLE: rappresenta il nome della tabella DynamoDB sulla quale si vogliono effettuare le operazioni.

# Creazione di un file .zip contenente il codice sorgente postItem.py
data "archive_file" "postItem_lambda_zip" {
  type        = "zip"
  source_file = "./lambda/postItem.py"
  output_path = "./lambda/zip/postitem_lambda.zip"
}

# Creazione di un file .zip contenente il codice sorgente getItem.py
data "archive_file" "getItem_lambda_zip" {
  type        = "zip"
  source_file = "./lambda/getItem.py"
  output_path = "./lambda/zip/getitem_lambda.zip"
}

# Creazione di un file .zip contenente il codice sorgente putItem.py
data "archive_file" "putItem_lambda_zip" {
  type        = "zip"
  source_file = "./lambda/putItem.py"
  output_path = "./lambda/zip/putitem_lambda.zip"
}

# Creazione di un file .zip contenente il codice sorgente deleteItem.py
data "archive_file" "deleteItem_lambda_zip" {
  type        = "zip"
  source_file = "./lambda/deleteItem.py"
  output_path = "./lambda/zip/deleteitem_lambda.zip"
}

# Creazione della funzione Lambda postItemHandler
resource "aws_lambda_function" "postItemHandler" {
  function_name = "postItemHandler"
  filename = "./lambda/zip/postitem_lambda.zip"
  handler = "postItem.lambda_handler"
  runtime = "python3.9"
  environment {
    variables = {
      REGION     = "eu-west-1"
      ITEM_TABLE = aws_dynamodb_table.item_table.name
   }
  }
  source_code_hash = data.archive_file.postItem_lambda_zip.output_base64sha256
  role = aws_iam_role.postItemLambdaRole.arn
  timeout     = "10"
  memory_size = "128"
}

# Creazione della funzione Lambda getItemHandler
resource "aws_lambda_function" "getItemHandler" {
  function_name = "getItemHandler"
  filename = "./lambda/zip/getitem_lambda.zip"
  handler = "getItem.lambda_handler"
  runtime = "python3.9"
  environment {
    variables = {
      REGION     = "eu-west-1"
      ITEM_TABLE = aws_dynamodb_table.item_table.name
   }
  }
  source_code_hash = data.archive_file.getItem_lambda_zip.output_base64sha256
  role = aws_iam_role.getItemLambdaRole.arn
  timeout     = "10"
  memory_size = "128"
}

# Creazione della funzione Lambda putItemHandler
resource "aws_lambda_function" "putItemHandler" {
  function_name = "putItemHandler"
  filename = "./lambda/zip/putitem_lambda.zip"
  handler = "putItem.lambda_handler"
  runtime = "python3.9"
  environment {
    variables = {
      REGION     = "eu-west-1"
      ITEM_TABLE = aws_dynamodb_table.item_table.name
   }
  }
  source_code_hash = data.archive_file.putItem_lambda_zip.output_base64sha256
  role = aws_iam_role.putItemLambdaRole.arn
  timeout     = "10"
  memory_size = "128"
}

# Creazione della funzione Lambda deleteItemHandler
resource "aws_lambda_function" "deleteItemHandler" {
  function_name = "deleteItemHandler"
  filename = "./lambda/zip/deleteitem_lambda.zip"
  handler = "deleteItem.lambda_handler"
  runtime = "python3.9"
  environment {
    variables = {
      REGION     = "eu-west-1"
      ITEM_TABLE = aws_dynamodb_table.item_table.name
   }
  }
  source_code_hash = data.archive_file.deleteItem_lambda_zip.output_base64sha256
  role = aws_iam_role.deleteItemLambdaRole.arn
  timeout     = "10"
  memory_size = "128"
}


# Creazione dell'integrazione tra l'API Gateway e la funzione Lambda postItemHandler
resource "aws_api_gateway_integration" "postitem-lambda-api" {
  rest_api_id             = aws_api_gateway_rest_api.item_apigw.id
  resource_id             = aws_api_gateway_method.postitem.resource_id
  http_method             = aws_api_gateway_method.postitem.http_method
  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = aws_lambda_function.postItemHandler.invoke_arn
}

# Creazione dell'integrazione tra l'API Gateway e la funzione Lambda getItemHandler
resource "aws_api_gateway_integration" "getitem-lambda-api" {
  rest_api_id             = aws_api_gateway_rest_api.item_apigw.id
  resource_id             = aws_api_gateway_method.getitem.resource_id
  http_method             = aws_api_gateway_method.getitem.http_method
  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = aws_lambda_function.getItemHandler.invoke_arn
}

# Creazione dell'integrazione tra l'API Gateway e la funzione Lambda putItemHandler
resource "aws_api_gateway_integration" "putitem-lambda-api" {
  rest_api_id             = aws_api_gateway_rest_api.item_apigw.id
  resource_id             = aws_api_gateway_method.putitem.resource_id
  http_method             = aws_api_gateway_method.putitem.http_method
  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = aws_lambda_function.putItemHandler.invoke_arn
}

# Creazione dell'integrazione tra l'API Gateway e la funzione Lambda deleteItemHandler
resource "aws_api_gateway_integration" "deleteitem-lambda-api" {
  rest_api_id             = aws_api_gateway_rest_api.item_apigw.id
  resource_id             = aws_api_gateway_method.deleteitem.resource_id
  http_method             = aws_api_gateway_method.deleteitem.http_method
  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = aws_lambda_function.deleteItemHandler.invoke_arn
}

# Definizione dei permessi per il servizio API Gateway per invocare la funzione Lambda postItemHandler
resource "aws_lambda_permission" "apigw-postItemHandler" {
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.postItemHandler.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_api_gateway_rest_api.item_apigw.execution_arn}/*/POST/item"
}

# Definizione dei permessi per il servizio API Gateway per invocare la funzione Lambda getItemHandler
resource "aws_lambda_permission" "apigw-getItemHandler" {
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.getItemHandler.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_api_gateway_rest_api.item_apigw.execution_arn}/*/GET/item"
}

# Definizione dei permessi per il servizio API Gateway per invocare la funzione Lambda putItemHandler
resource "aws_lambda_permission" "apigw-putItemHandler" {
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.putItemHandler.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_api_gateway_rest_api.item_apigw.execution_arn}/*/PUT/item"
}

# Definizione dei permessi per il servizio API Gateway per invocare la funzione Lambda deleteItemHandler
resource "aws_lambda_permission" "apigw-deleteItemHandler" {
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.deleteItemHandler.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_api_gateway_rest_api.item_apigw.execution_arn}/*/DELETE/item"
}



# Deployment dell'API Gateway in uno stage denominato "prod"
resource "aws_api_gateway_deployment" "item_api_stage_prod" {
  depends_on  = [
    aws_api_gateway_method.postitem,
    aws_api_gateway_integration.postitem-lambda-api,
    aws_api_gateway_method.getitem,
    aws_api_gateway_integration.getitem-lambda-api,
    aws_api_gateway_method.putitem,
    aws_api_gateway_integration.putitem-lambda-api,
    aws_api_gateway_method.deleteitem,
    aws_api_gateway_integration.deleteitem-lambda-api,
  ]
  rest_api_id = aws_api_gateway_rest_api.item_apigw.id
  stage_name  = "prod"
}
