# terraform-fastapi-on-lambda

A motivação desse projeto é de forma fácil poder subir uma aplicação no lambda e fazer algum tratamento da request de forma bem mais barata que um zapier ou alternativa no/low code, mesmo sendo com alguma peça de código


# Deploy
- Fazer um terraform apply, criar ECR (vai falhar da primeira vez por precisar da imagem, basta ir para o próxima etapa)
- Preencher o .env com a base url da sua conta AWS (que aparecer nas instruções de push do seu ecr) 
- Subir a Imagem
- A partir desse momento para os próximos tudo é simplificado com o comando `Make deploy`


# Comentários

Fizemos baseado no docker e no ecr para não limitarmos os pacotes utilizados e assim possibilitar aplicações robustas via http ainda