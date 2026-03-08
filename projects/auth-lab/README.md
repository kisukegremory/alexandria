
### 📂 Estrutura do Projeto: `auth-lab`

Queremos construir uma jornada de aprendizado progressiva, onde cada projeto é um passo para entender o próximo. A ideia é começar do zero, sem frameworks, e ir evoluindo até chegar em casos de uso mais complexos e realistas, embora esse projeto será guiado por IA, minha meta é que seja um grande aprendizado, não apenas uma coleção de códigos.

#### 🟢 Nível 1: A Base da "Ciência" (Sem Frameworks)

*O objetivo aqui é entender a matemática e a estrutura de dados. Nada de caixas pretas.*

**1. `01-jwt-symmetric-raw` (O Segredo Compartilhado)**

* **Conceito:** Assinatura Simétrica (HMAC + SHA256 / `HS256`).
* **O Projeto:** Um script simples em **Golang** que cria um token e outro que valida.
* **O Desafio:** Ambos usam a mesma senha (`my-secret-key`). Se o validador não tiver a senha exata, o token é inválido.
* **Lição:** Entender a estrutura `Header.Payload.Signature` e que qualquer um pode ler o payload (Base64), mas ninguém pode alterar sem a senha.

**2. `02-jwt-asymmetric-rsa` (A Chave do Rei)**

* **Conceito:** Criptografia Assimétrica (RSA / `RS256`). O padrão da indústria.
* **O Projeto:**
* Gerar um par de chaves `.pem` (Privada e Pública) via OpenSSL.
* Script **Emissor (Issuer)**: Assina com a *Private Key*.
* Script **Validador (Gatekeeper)**: Valida com a *Public Key*.


* **Lição:** O Validador não precisa guardar segredos. Ele pode ser público. Isso é a base de como o Keycloak funciona.

#### 🟡 Nível 2: A Arquitetura Cliente-Servidor (Protocolos)

*Aqui introduzimos a separação de responsabilidades e regras de negócio.*

**3. `03-audience-trap` (O Porteiro Cético)**

* **Conceito:** Claims de Validação (`iss`, `sub`, `aud`, `exp`).
* **O Projeto:**
* **Backend (API Golang):** Um servidor HTTP simples que expõe `/secreto`. Ele espera `aud: "alexandria-backend"`.
* **Cliente (Script):** Tenta acessar a API com um token válido, mas com `aud: "marketing-app"`.


* **Lição:** Entender o *Confused Deputy Problem*. Um token válido para o Vizinho não serve para mim.

**4. `04-oauth2-flow-manual` (O Aperto de Mão)**

* **Conceito:** OAuth 2.0 básico (Authorization Code Flow) "na unha".
* **O Projeto:**
* Subir um **Keycloak** (Docker).
* Criar um cliente "Confidential" (Backend-to-Backend).
* Fazer as requisições HTTP manuais (sem libs de auth) para trocar `client_id` + `client_secret` por um `access_token`.


* **Lição:** Entender os endpoints `/auth`, `/token` e `/userinfo`. Ver o JSON de resposta cru.

#### 🔴 Nível 3: O Mundo Real (Front, CLIs e Segurança Avançada)

*Aqui entra a complexidade de aplicações distribuídas.*

**5. `05-cli-pkce-auth` (Projeto Nina/Vctl)**

* **Conceito:** **PKCE** (Proof Key for Code Exchange). Obrigatório para Apps Públicos (SPAs, Mobile e CLIs) que não podem guardar segredos.
* **O Projeto:**
* Criar uma pequena CLI em **Golang** (`nina-login`).
* Ela abre o navegador do usuário para logar no Keycloak.
* Ela escuta numa porta local (callback) para receber o código.
* Ela troca o código pelo token usando o desafio PKCE (S256).


* **Lição:** Como autenticar usuários em ferramentas de linha de comando (CLI) de forma segura, igual ao `aws sso login`.

**6. `06-jwks-endpoint` (A Rotação de Chaves)**

* **Conceito:** JSON Web Key Sets (JWKS).
* **O Projeto:**
* Backend em **Golang** que não tem a chave pública "hardcoded" (colada no código).
* Ele busca a chave pública dinamicamente no endpoint do Keycloak (`/certs`).
* Implementar cache (para não bater no Keycloak a cada request).


* **Lição:** Como funciona a rotação automática de credenciais sem derrubar a aplicação.

#### 🟣 Nível 4: Staff Engineer / Cloud Native (A "Preguiça Inteligente")

*Deixar a infraestrutura trabalhar por você.*

**7. `07-aws-cognito-wrapper` (O Ecossistema AWS)**

* **Conceito:** User Pools e Identity Pools.
* **O Projeto:**
* Criar um User Pool no Terraform.
* Trocar o Keycloak pelo Cognito no projeto da CLI (`05`).


* **Lição:** Diferenças entre OIDC padrão (Keycloak) e as idiossincrasias da AWS.

**8. `08-alb-authentication` (O Gatekeeper de Infra)**

* **Conceito:** Offloading de Autenticação.
* **O Projeto:**
* Subir uma API "boba" que retorna "Olá, [User]" lendo apenas headers.
* Configurar um **ALB (Application Load Balancer)** com Terraform.
* Ligar a regra de Listener do ALB ao Cognito (ou Keycloak OIDC).


* **Lição:** Zero Trust na borda. A requisição nem chega no container se não estiver autenticada. "Intelligent Laziness" aplicada ao máximo.

**9. `09-m2m-service-mesh` (Robô falando com Robô)**

* **Conceito:** Client Credentials Flow (Machine to Machine).
* **O Projeto:**
* Serviço A (Cronjob de ETL) precisa falar com Serviço B (API de Dados).
* Sem usuário humano.
* Implementar a rotação automática de tokens quando eles expiram no meio de um processo longo.


* **Lição:** Autenticação de serviços em background e workers.