import logging
import boto3
import json
import os

# Inizializza il client DynamoDB
session = boto3.Session(region_name=os.environ['REGION'])
dynamodb_client = session.client('dynamodb')

def lambda_handler(event, context):
    try:
        # Estrai i parametri dalla query string
        params = event.get('queryStringParameters', {})
        item_id = params.get('item_id')

        if item_id:
            logging.info(f'Received request to delete item with item_id: {item_id}')
            
            # Cerca l'item nella tabella DynamoDB
            response = dynamodb_client.get_item(
                TableName = os.environ["ITEM_TABLE"],
                Key = {
                    'item_id': {'S': item_id}
                }
            )
            item = response.get('Item')
            if item:
                # Elimina l'item dalla tabella DynamoDB
                response = dynamodb_client.delete_item(
                    TableName=os.environ["ITEM_TABLE"],
                    Key={'item_id': {'S': item_id}}
                )

                # Verifica se l'eliminazione è riuscita
                if response['ResponseMetadata']['HTTPStatusCode'] == 200:
                    return {
                        'statusCode': 200,
                        'body': json.dumps({'message': 'Item deleted successfully!'})
                    }
                else:
                    return {
                        'statusCode': response['ResponseMetadata']['HTTPStatusCode'],
                        'body': json.dumps({'message': 'Failed to delete the item.'})
                    }
            else:
                return {
                'statusCode': 400,
                'body': json.dumps({'message': 'No item found with the specified ID.'})
            }
        else:
            return {
                'statusCode': 400,
                'body': json.dumps({'message': 'Missing the item_id parameter in the query string.'})
            }
    except Exception as e:
        error_message = 'Server error: ' + str(e)
        logging.error(error_message)
        return {
            'statusCode': 500,
            'body': json.dumps({'message': error_message})
        }
