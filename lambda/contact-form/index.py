import json
import boto3
import os

ses = boto3.client('ses', region_name='ap-south-1')

def handler(event, context):
    try:
        body = json.loads(event.get('body', '{}'))
        name    = body.get('name', '').strip()
        email   = body.get('email', '').strip()
        message = body.get('message', '').strip()

        if not name or not email or not message:
            return {
                'statusCode': 400,
                'headers': cors_headers(),
                'body': json.dumps({'error': 'All fields are required'})
            }

        ses.send_email(
            Source=os.environ['TO_EMAIL'],
            Destination={'ToAddresses': [os.environ['TO_EMAIL']]},
            Message={
                'Subject': {'Data': f'Portfolio Contact from {name}'},
                'Body': {
                    'Text': {
                        'Data': f'Name: {name}\nEmail: {email}\n\nMessage:\n{message}'
                    },
                    'Html': {
                        'Data': f'''
                        <h2>New message from your portfolio</h2>
                        <p><strong>Name:</strong> {name}</p>
                        <p><strong>Email:</strong> <a href="mailto:{email}">{email}</a></p>
                        <p><strong>Message:</strong></p>
                        <p>{message}</p>
                        '''
                    }
                }
            },
            ReplyToAddresses=[email]
        )

        return {
            'statusCode': 200,
            'headers': cors_headers(),
            'body': json.dumps({'message': 'Email sent successfully'})
        }

    except Exception as e:
        print(f'Error: {str(e)}')
        return {
            'statusCode': 500,
            'headers': cors_headers(),
            'body': json.dumps({'error': 'Failed to send email'})
        }

def cors_headers():
    return {
        'Access-Control-Allow-Origin': '*',
        'Access-Control-Allow-Headers': 'content-type',
        'Access-Control-Allow-Methods': 'POST, OPTIONS'
    }
