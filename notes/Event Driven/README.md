# Atuação em Eventos


# EventBridge
- Tem ações scheduladas
- Event Patterns tambem (ex: email ao alguem logar)
- Rules são o meio do caminho entre:
    - sources com filtros (eventos do ec2, codepipeline, cloudtrail,...)
    - até destinations (lambda, task em ecs, batch, code pipeline, step functions...)
- Event bus (barramento)
    - o default é para eventos entre serviços da AWS
    - Partners é por exemplo com datadog, zendesk envia para cá
    - custom é algo que você pode configurar para si
- consegue inferir um schema baseado nos eventos no barramento e registrar ou você pode definir por si próprio (schema registry)
