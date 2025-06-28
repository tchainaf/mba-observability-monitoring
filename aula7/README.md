# 🚀 ELK Stack 2025 - Lab Aula 7

## Monitoramento Avançado de Logs com Elasticsearch, Logstash e Kibana

---

## 📋 **Pré-requisitos**
- Docker 20.0+ instalado
- Docker Compose 2.0+ instalado  
- 6GB+ de RAM disponível
- 5GB+ de espaço em disco

---

## 🔧 **Passo 1: Instalar Docker Compose (se necessário)**

```bash
# Instalar Docker Compose
sudo apt update
sudo apt install -y docker-compose

# Verificar instalação
docker-compose --version
```

---

## 📥 **Passo 2: Clone o Repositório** 

```bash
# Clone o repositório do curso
git clone https://github.com/able2cloud/continuous_monitoring_log_analytics.git

# Entre no diretório da aula 7
cd continuous_monitoring_log_analytics/aulas_2025/aula7
```

---

## 🚀 **Passo 3: Execute o Script Automático**

```bash
# Torne o script executável e execute
chmod +x start.sh
./start.sh
```

**O script irá automaticamente:**
- ✅ Verificar pré-requisitos
- ✅ Configurar o sistema
- ✅ Baixar imagens Docker
- ✅ Iniciar todos os serviços
- ✅ Gerar logs de teste

---

## 🌐 **Passo 4: Acesse as Interfaces**

- **Aplicação Web**: http://`<IP_PUBLICO_DA_EC2>` *(gere logs aqui)*
- **Kibana**: http://`<IP_PUBLICO_DA_EC2>`:5601 *(visualize os dados)*
- **Elasticsearch**: http://`<IP_PUBLICO_DA_EC2>`:9200 *(API de dados)*

---

## 🔧 **Como o Nginx Funciona Neste Lab**

### **Configuração Automática**
O Nginx é automaticamente configurado pelo Docker Compose com:

- **Logs em formato JSON** - Para facilitar o parsing
- **Interface web interativa** - Para gerar logs de teste
- **Endpoints de monitoramento** - Para health checks

### **Estrutura dos Logs**
O Nginx gera logs estruturados em JSON com campos importantes:
```json
{
  "time_local": "25/Dec/2025:10:30:45 +0000",
  "remote_addr": "172.17.0.1",
  "status": "200",
  "request_time": "0.001",
  "http_user_agent": "Mozilla/5.0...",
  "request": "GET / HTTP/1.1"
}
```

### **Fluxo dos Logs**
```
Nginx → Logs JSON → Filebeat/Logstash → Elasticsearch → Kibana
```

---

## 📊 **Passo 5: Configurar Kibana**

1. **Acesse Kibana**: http://`<IP_PUBLICO_DA_EC2>`:5601
2. **Vá para**: Stack Management → Index Patterns
3. **Crie os index patterns**:
   - `logstash-nginx-*` (Time field: `@timestamp`)
   - `filebeat-nginx-*` (Time field: `@timestamp`)
   - `metricbeat-*` (Time field: `@timestamp`)

---

## 🎯 **Passo 6: Gerar Logs de Teste**

**Acesse**: http://`<IP_PUBLICO_DA_EC2>`

Use os botões da interface:
- ✅ **Sucesso (200)** - Requisições OK
- ❌ **Erro 404** - Páginas não encontradas  
- 💥 **Erro 500** - Erros de servidor
- 🚀 **Múltiplas Requisições** - Teste de volume

---

## 🔍 **Passo 7: Visualizar no Kibana**

1. **Vá para**: Discover
2. **Selecione**: `logstash-nginx-*`
3. **Explore os campos**:
   - `remote_addr` - IP do cliente
   - `status` - Código HTTP
   - `request_time` - Tempo de resposta
   - `geoip.*` - Localização geográfica

---

## 🛠️ **Comandos Úteis**

```bash
# Ver status dos serviços
docker-compose ps

# Ver logs em tempo real
docker-compose logs -f

# Parar tudo
docker-compose down

# Reiniciar
docker-compose restart
```

---

## 🐛 **Problemas Comuns**

**Elasticsearch não inicia:**
```bash
sudo sysctl -w vm.max_map_count=262144
```

**Verificar se tudo está funcionando:**
```bash
curl http://localhost:9200/_cluster/health
curl http://localhost:5601/api/status
```

---

**🎓 Desenvolvido para fins educacionais - Able2Cloud 2025** 