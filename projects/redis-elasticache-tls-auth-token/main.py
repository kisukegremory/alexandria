import redis
from redis.exceptions import ConnectionError, AuthenticationError
import ssl
import os # Recomendado para gerenciar variáveis de ambiente

# --- Configurações de Conexão (Substitua pelos seus dados) ---
# O endpoint do seu ElastiCache Redis (Geralmente tem o formato:
# <nome-do-cluster>.<id>.região.cache.amazonaws.com)
REDIS_HOST = os.environ.get("REDIS_HOST")

# A porta padrão para conexões TLS/SSL no Redis ElastiCache é 6379 ou 6380.
# Verifique a porta do seu cluster.
REDIS_PORT = int(os.environ.get("REDIS_PORT", 6379))

# O Token de Autenticação (AUTH Token) configurado no seu cluster ElastiCache.
# **Importante:** Não armazene o token diretamente no código. Use variáveis de
# ambiente, AWS Secrets Manager ou outro serviço de segredos.
AUTH_TOKEN = os.environ.get("REDIS_AUTH_TOKEN")

# --- Configuração de Certificado (Opcional, mas recomendado para produção) ---
# Se você deseja uma verificação de certificado mais rigorosa (Mutual TLS),
# defina 'ssl_cert_reqs' para 'ssl.CERT_REQUIRED' e especifique 'ssl_ca_certs'
# com o caminho para o certificado CA da Amazon.

# A AWS fornece um certificado CA para ElastiCache. Para ElastiCache Redis,
# geralmente não é necessário especificar o certificado CA, pois 'ssl=True' e
# 'ssl_cert_reqs=ssl.CERT_NONE' (ou 'ssl.CERT_OPTIONAL') geralmente funcionam,
# mas para maior segurança, você pode usar 'ssl.CERT_REQUIRED' com o CA
# da Amazon.

# Para simplificar e demonstrar a conexão básica com TLS e AUTH Token:
SSL_CERT_REQS = ssl.CERT_NONE # Altere para ssl.CERT_REQUIRED para verificação mais rigorosa

try:
    # Cria uma instância do cliente Redis.
    # - host/port: O endpoint e a porta do ElastiCache.
    # - password: É usado para o comando AUTH do Redis.
    # - ssl: Define para True para habilitar a criptografia TLS/SSL (in-transit encryption).
    # - ssl_cert_reqs: Define o nível de verificação de certificado.
    redis_client = redis.StrictRedis(
        host=REDIS_HOST,
        port=REDIS_PORT,
        password=AUTH_TOKEN,
        ssl=True,  # Habilita a criptografia TLS
        ssl_cert_reqs=SSL_CERT_REQS,
        decode_responses=True # Decodifica as respostas para strings Python
    )

    # Teste de Conexão
    print(f"Tentando conectar a Redis em: {REDIS_HOST}:{REDIS_PORT} com TLS e AUTH Token...")
    redis_client.ping()
    print("✅ Conexão segura com Redis estabelecida com sucesso! (PING PONG)")

    # Exemplo de Operações
    key = "minha_chave_segura"
    value = "dados_criptografados"

    # Definir uma chave
    redis_client.set(key, value)
    print(f"Set: {key} = {value}")

    # Obter uma chave
    retrieved_value = redis_client.get(key)
    print(f"Get: {key} = {retrieved_value}")

    # Limpar (opcional)
    redis_client.delete(key)
    print(f"Delete: {key} (Chave removida)")

    # Fechar a conexão
    redis_client.close()
except AuthenticationError as e:
    print(f"❌ Erro de Autenticação: {e}")
    print("Verifique se o token de autenticação está correto e se o cluster está configurado para AUTH.")
except ConnectionError as e:
    print(f"❌ Erro de Conexão com Redis: {e}")
    print("Verifique se o endpoint, a porta, o token, as configurações de segurança do VPC e o TLS estão corretos.")
except Exception as e:
    print(f"❌ Ocorreu um erro inesperado: {e}")