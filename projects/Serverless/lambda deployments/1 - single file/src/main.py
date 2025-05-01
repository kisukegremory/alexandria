

def lambda_handler(event, context=None):

    return {
        'statusCode':200,
        'coxinha?': "sim",
        'event': event
    }

if __name__ == "__main__":
    print(lambda_handler("batata","salada")) #{'statusCode': 200, 'coxinha?': 'sim', 'event': 'batata'}