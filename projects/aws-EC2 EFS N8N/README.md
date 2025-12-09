# N8N na AWS com terraform!

Nos baseando na arquitetura abaixo, exportaremos um target group para nosso load balancer e importaremos o security group dele para fechar o tráfego inbound só pra ele:

![alt text](images/image.png)

# Já tenho um load balancer, só preciso integrar nele

Precisamos só prover um target group para que você possa conectar um listener rule no seu load balancer, portanto vamos fazer só a parte computacional do setup:

- EFS: como um pendrive compartilhado espetado dentro do nosso EC2, mesmo se nossas instâncias cairem, os dados do n8n estão protegidos (por que não usar um DB no RDS? significaria +11$ no projeto o que não justifica muito se com Backups az no EFS temos uma resiliência muito similar) 
- EC2: Para rodar um docker com o N8N, configurar a pasta que vamos mapear nosso "pendrive" EFS e configurar o docker volume para apontar pra lá!
- Auto Scalling Group + Schedules: para desligar nosso projeto fora dos horários úteis que não estivermos trabalhando para economizar um pouco a mais!
- Target Group: para que todas nossas instâncias estejam mapeadas no mesmo lugar, e aí só apontar um listener do nosso load balancer para ele!


# O que é necessário ter anterior ao nosso terraform?
- Já ter criado dominio criado na AWS (route 53) (em menos de 5 mins você compra seu dominio lá ex: gatosedados.com)
- Um certificado ssl/tls no via AWS ACM certificate (é rapidinho, só colocar o seu dominio lá e tambem o *.seudominio.com)

# O que preciso alterar no terraform?
- Literalmente só o id do security group do seu load balancer nas variáveis
- Host name/subdominio/DNS em que irá hospedar o serviço, ex: workflows.gatosedados.com

# O que posso alterar?
- VPC e subnet em que o projeto será deployado (necessário ajustar EC2 AutoScalling e EFS)
- Variáveis de ambiente do N8N (no user-data do template ec2)
- Tamanho da instância e número de instâncias (ec2)
- 