# Laboratório Atualizado: Jaeger para Rastreamento Distribuído com Docker Compose

Este guia demonstra como configurar e utilizar o Jaeger para rastreamento distribuído (distributed tracing) usando Docker Compose. Ele abrange:
- Configuração de um ambiente com Docker Compose
- Implementação de uma aplicação Python simples que envia spans para o Jaeger
- Visualização e análise de traces na interface gráfica do Jaeger

✅ **Data da Atualização: 7 de Abril de 2025**

---

## 1. Estrutura do Projeto

```
jaeger-demo/
├── app.py                # Aplicação Python que envia spans para o Jaeger
├── Dockerfile            # Definição da imagem Docker para a aplicação Python
├── docker-compose.yml    # Configuração do Docker Compose com Jaeger e a aplicação
└── requirements.txt      # Dependências Python necessárias
```

---

## 2. Configuração do Ambiente

### 2.1. Obter o Código-fonte
```bash
git clone https://github.com/able2cloud/continuous_monitoring_log_analytics.git
cd continuous_monitoring_log_analytics/aulas_2024/aula7/jaeger-demo
```

---

## 3. Arquivos do Projeto

### 3.1. app.py - Aplicação Python
```python
import time
import opentracing
from jaeger_client import Config

def init_jaeger_tracer(service_name='my_service'):
    config = Config(
        config={
            'sampler': {'type': 'const', 'param': 1},
            'logging': True,
        },
        service_name=service_name,
        validate=True,
    )
    return config.initialize_tracer()

if __name__ == "__main__":
    tracer = init_jaeger_tracer()
    with tracer.start_span('test_span') as span:
        span.set_tag('example_tag', 'test_value')
        span.log_kv({'event': 'test_message', 'life': 42})
        time.sleep(1)
    tracer.close()
```

### 3.2. requirements.txt - Dependências Python
```
opentracing
jaeger-client
```

### 3.3. Dockerfile - Definição da Imagem Docker
```dockerfile
# Use uma imagem base oficial do Python
FROM python:3.12

# Defina o diretório de trabalho
WORKDIR /app

# Copie os arquivos de requisitos
COPY requirements.txt .

# Instale as dependências
RUN pip install --no-cache-dir -r requirements.txt

# Copie o restante dos arquivos da aplicação
COPY . .

# Comando para executar a aplicação
CMD ["python", "app.py"]
```

### 3.4. docker-compose.yml - Configuração dos Serviços
```yaml
version: '3'

services:
  jaeger:
    image: jaegertracing/all-in-one:1.29
    ports:
      - "5775:5775/udp"
      - "6831:6831/udp"
      - "6832:6832/udp"
      - "5778:5778"
      - "16686:16686"
      - "14268:14268"
      - "14250:14250"
      - "9411:9411"
    environment:
      - COLLECTOR_ZIPKIN_HTTP_PORT=9411

  python-app:
    build: .
    environment:
      - JAEGER_AGENT_HOST=jaeger
    depends_on:
      - jaeger
```

---

## 4. Executando a Demo

### 4.1. Construir e Iniciar os Contêineres
```bash
docker-compose up --build
```

### 4.2. Acessar a Interface do Jaeger
Após iniciar os contêineres, acesse a interface do Jaeger no seu navegador:
```
http://localhost:16686
```

---

## 5. Visualização dos Traces

### 5.1. Passos para Visualizar os Traces
1. Acesse http://localhost:16686 no seu navegador.
2. No campo "Service" (Serviço), selecione `my_service` (nome do serviço definido no script Python).
3. Clique em "Find Traces" (Encontrar Traces).
4. Uma lista de traces será exibida. Clique em qualquer trace para visualizar detalhes, incluindo:
   - Spans
   - Tags
   - Logs
   - Tempo de execução 