# Site Estático com S3

# Quero usar, como faço?
1. Tenha as credenciais da AWS setadas no seu ambiente
2. Rode o `make complete-setup`, só isso, ele irá orchestrar os terraforms, subir o html, liberar acesso ao bucket e gerar a url no final para acesso :D
3. Para destruir tudo só rodar o `make complete-destroy`



# Notas para criar o projeto
1. Precisa liberar acesso ao público
2. Resource access policy aberto
3. Habilitar hospedagem de site estatico
    - especificar arquivo index
    - regra de erro (error.html)


Vamos dividir o projeto em 3 etapas:
*Não é recomendado utilizar backend local, mas para encadear o site para todos, vamos fazer dessa forma*
1. Prerequirements: Criação de Bucket
2. Site: Subir index.html, error.html (opcional)
3. Disponibilizar ao público: Liberar acesso
