import boto3
import uuid
import time
import random

session = boto3.Session(profile_name='nina', region_name='us-east-1')
dynamodb = session.resource('dynamodb')

table_name = 'dynamo-cdc-to-athena-user-table'
table = dynamodb.Table(table_name)

def generate_user():
    """Gera um payload de usuário simulado."""
    return {
        'user_id': str(uuid.uuid4()),
        'name': f"User_{random.randint(1000, 9999)}",
        'plan': random.choice(['FREE', 'PRO', 'ENTERPRISE']),
        'is_active': True
    }

def main():
    print(f"🚀 Iniciando testes de carga na tabela {table_name}...")
    
    users_created = []

    # 1. Simular INSERTS (Criação de novos usuários)
    print("\n[1/3] Gerando eventos de INSERT...")
    for _ in range(5):
        user = generate_user()
        table.put_item(Item=user)
        users_created.append(user['user_id'])
        print(f"  + Inserido: {user['user_id']}")
        time.sleep(0.5) # Pausa pequena para não encavalar os timestamps

    # 2. Simular MODIFIES (Atualização de usuários existentes)
    print("\n[2/3] Gerando eventos de MODIFY...")
    user_to_update = users_created[0]
    table.update_item(
        Key={'user_id': user_to_update},
        UpdateExpression="SET #p = :val",
        ExpressionAttributeNames={'#p': 'plan'}, # O HACK: alias para driblar a palavra reservada
        ExpressionAttributeValues={':val': 'STAFF_ENGINEER_PLAN'}
    )
    print(f"  ~ Atualizado: {user_to_update}")
    # 3. Simular REMOVES (Deleção de usuários)
    print("\n[3/3] Gerando eventos de REMOVE...")
    user_to_delete = users_created[1]
    table.delete_item(
        Key={'user_id': user_to_delete}
    )
    print(f"  - Deletado: {user_to_delete}")

    print("\n✅ Carga de dados finalizada!")
    print("⏳ Agora aguarde o buffer do Kinesis Firehose (configurado para 60 segundos no seu kinesis.tf).")
    print("Siga para o console do S3 para ver os arquivos Parquet sendo gerados no prefixo 'users_events/'.")

if __name__ == '__main__':
    main()