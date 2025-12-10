Trivy é uma ferramenta bem interessante para se adicionar no CI, ela consegue scannear imagens, file systens e arquivos de configuração como CDK e Terraform, embora pelos testes o Terraform tem bastante falso positivo, para instalar ele usei a recomendação para debian/ubuntu pelo site da documentação, um simples copy paste no terminal, referência: https://trivy.dev/docs/latest/getting-started/installation/

Para usar localmente deixo os exemplos abaixo, tanto de forma simples, quando com exit code que faz stop em um actions e tem filtro de severidade:

```
trivy image serverless-interaction/api:latest
trivy image --exit-code 1 --severity HIGH serverless-interaction/api:latest
```

Para rodar sobre configurações terraform é ainda mais simples com:
```
trivy config .
```

Para integrar na esteira de CI, recomendaria usar o Actions diretamente com a documentação deles mesmo: https://github.com/aquasecurity/trivy-action
