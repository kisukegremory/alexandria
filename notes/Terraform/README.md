# Terraform


é possível usar operador ternário no terraform:
`count = var.env == 'prod'? 2 : 1`

Quando tiver mais de um recurso feito pelo count, serão referenciados como uma lista [], então aws_instance[0],...

Para atualizar a versão dos providers:
`terraform init -upgrade`

Para atualizar o tfstate com o backend:
`terraform refresh`

Funções:
```terraform
lookup(dict, value)
ex: ami = lookup(ami_dict, 'us-east-1')
```

`terraform` validate verifica se os atributos de um recurso estão setados corretamente


dynamic blocks
podemos fazer uma lista ex uma lista de port dentro de um aws_security_group
e no resource fazer:
dynamic ingress {
    for_each = var.ports
    iterator = port
    content {
        from_port = port
        to_port = port
        protocol = "tcp"
        cidr_block = "0.0.0.0/0"
    }
}