import boto3
from pprint import pprint

sts_client = boto3.client('sts')
ec2_client = boto3.client('ec2')

def get_acount_ids(user_parameters):
    account_ids = []
    try:
        user_parameters["target_accounts"]
    except Exception as error:
        print error
        raise
    return account_ids


def share_image(image_id, account_ids):
    try:
        response = ec2_client.modify_image_attribute(
            Attribute='launchPermission',
            OperationType='add',
            UserIds=account_ids,
            ImageId=image_id
        )
        print("Success! AMI " + image_id + "has been shared to accounts:")
        pprint(account_ids)
    except Exception as error:
        print error
        raise


def get_image_id(user_parameters):
    image_ids = []
    try:
        response = ec2_client.describe_images(
            Owners=[
                user_parameters["source_accounts"]
            ],
            Filters=[
                {
                    'Name': 'tag:Stage',
                    'Values': ['Stable']
                }
            ]
        )
        for image in response['Images']:
            image_ids.append(image['ImageId'])
    except Exception as error:
        print error
        raise

    return image_ids


def handler(event, context):
    user_parameters = event["CodePipeline.job"]['data']['actionConfiguration']['configuration']['UserParameters']
    decoded_user_parameters = json.loads(user_parameters)
    account_ids = get_acount_ids(decoded_user_parameters)
    image_ids = get_image_id(decoded_user_parameters)
    share_image(image_id, account_ids)
