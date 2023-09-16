import logging
import boto3
import json
import os

session = boto3.Session(region_name = os.environ['REGION'])
dynamodb_client = session.client('dynamodb')


def lambda_handler(event, context):
    try:    
        params = event['queryStringParameters']
        if params and 'item_id' in params:
            logging.info(params)
            item_id = params['item_id']
            logging.info(f'item_id: {item_id}')

            response = dynamodb_client.get_item(
                TableName = os.environ["ITEM_TABLE"],
                Key = {
                    'item_id': {'S': item_id}
                }
            )
            item = response.get('Item')
            if item:
                response = {
                    "item_id": item["item_id"]["S"],
                    "item_name": item["item_name"]["S"],
                    "item_category": item["item_category"]["S"],
                    "item_price": float(item["item_price"]["N"])
                }
                return {
                    'statusCode': 200,                    
                    'body': json.dumps(response)
                }
            else:
                error_message = 'Item not found.'
                logging.error({'message': error_message})
                return {
                    'statusCode': 404,
                    'body': json.dumps({'message': error_message})
                }
        else:
            dynamodb_response = dynamodb_client.scan(
                TableName = os.environ["ITEM_TABLE"]
            )

            items = []
            for item in dynamodb_response.get("Items", []):
                items.append({
                    "item_id": item["item_id"]["S"],
                    "item_name": item["item_name"]["S"],
                    "item_category": item["item_category"]["S"],
                    "item_price": float(item["item_price"]["N"])
                })
            logging.info(items)
            return {
                'statusCode': 200,
                'body': json.dumps(items)
            }
    except Exception as e:
        logging.error(e)
        return {
            'statusCode': 500,
            'body': '{"status":"Server error."}'           
        }
