import boto3
import uuid
import time
import random
import os

TABLE_NAME = os.getenv('TABLE_NAME', 'tabela-nina') # Podemos usar o terraform output aqui para orquestrar o nome da tabela dinamicamente
AWS_PROFILE = os.getenv('AWS_PROFILE', 'nina')
AWS_REGION = os.getenv('AWS_REGION', 'us-east-1')

session = boto3.Session(region_name=AWS_REGION, profile_name=AWS_PROFILE)
dynamodb = session.resource('dynamodb')

table = dynamodb.Table(TABLE_NAME)

def generate_user():
    """Gera um payload de usuário simulado."""
    return {
        'user_id': str(uuid.uuid4()),
        'name': f"User_{random.randint(1000, 9999)}",
        'plan': random.choice(['FREE', 'PRO', 'ENTERPRISE']),
        'is_active': True
    }

def main():
    print(f"🚀 Iniciando testes de carga na tabela {TABLE_NAME}...")
    
    users_created = []

    # 1. Simular INSERTS (Criação de novos usuários)
    print("Gerando eventos...\n")
    while True:
        user = generate_user()
        table.put_item(Item=user)
        users_created.append(user['user_id'])
        print(f"  + Inserido: {user['user_id']}")
        time.sleep(0.5) # Pausa pequena para não encavalar os timestamps

if __name__ == '__main__':
    main()