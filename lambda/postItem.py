import logging
import boto3
import json
import os

session = boto3.Session(region_name = os.environ['REGION'])
dynamodb_client = session.client('dynamodb')

def lambda_handler(event, context):
    try:
        logging.info("event ->" + str(event))
        payload = json.loads(event["body"])
        logging.info("payload ->" + str(payload))

        # Verifica se gli attributi richiesti sono presenti nel payload
        required_attributes = ['item_id', 'item_name', 'item_category', 'item_price']
        if all(attr in payload for attr in required_attributes):
            
            dynamodb_response = dynamodb_client.get_item(
                TableName = os.environ["ITEM_TABLE"],
                Key = {
                    'item_id': {'S': payload["item_id"]}
                }
            )
            check_item = dynamodb_response.get('Item')

            if check_item:
                error_message = 'An Item with the same ID already exists.'
                logging.error({'message': error_message})
                return {
                    'statusCode': 400,
                    'body': json.dumps({'message': error_message})
                }
            else:
                item = {
                    "item_id": {"S": payload["item_id"]},
                    "item_name": {"S": payload["item_name"]},
                    "item_category": {"S": payload["item_category"]},
                    "item_price": {"N": str(payload["item_price"])}
                }
                dynamodb_response = dynamodb_client.put_item(
                    TableName = os.environ["ITEM_TABLE"],
                    Item = item
                )
                logging.info("DynamoDB response: " + json.dumps(dynamodb_response))
                return {
                    'statusCode': 201,
                    'body': 'Item created correctly!'
                }
        else:
            error_message = 'Missing some parameters in the body of the request.'
            logging.error({'message': error_message})
            return {
                'statusCode': 400,
                'body': json.dumps({'message': error_message})
            }
    except Exception as e:
        error_message = 'Server error: ' + str(e)
        logging.error(error_message)
        return {
            'statusCode': 500,
            'body': json.dumps({'message': error_message})
        }





