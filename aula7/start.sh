#!/bin/bash

# ELK Stack 2025 - Script de Inicialização
# Autor: Able2Cloud
# Data: 2025

set -e

# Cores para output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Função para logging
log() {
    echo -e "${GREEN}[$(date +'%Y-%m-%d %H:%M:%S')] $1${NC}"
}

warn() {
    echo -e "${YELLOW}[$(date +'%Y-%m-%d %H:%M:%S')] WARNING: $1${NC}"
}

error() {
    echo -e "${RED}[$(date +'%Y-%m-%d %H:%M:%S')] ERROR: $1${NC}"
}

# Banner
echo -e "${BLUE}"
echo "╔══════════════════════════════════════════════════════════╗"
echo "║                   🚀 ELK Stack 2025                      ║"
echo "║          Monitoramento Avançado de Logs                  ║"
echo "║                                                          ║"
echo "║    Elasticsearch 8.11.3 + Logstash + Kibana            ║"
echo "║         + Filebeat + Metricbeat + Nginx                 ║"
echo "╚══════════════════════════════════════════════════════════╝"
echo -e "${NC}"

# Verificar pré-requisitos
log "Verificando pré-requisitos..."

# Verificar Docker
if ! command -v docker &> /dev/null; then
    error "Docker não está instalado. Por favor, instale o Docker primeiro."
    exit 1
fi

# Verificar Docker Compose
if ! command -v docker compose &> /dev/null; then
    error "Docker Compose não está instalado. Por favor, instale o Docker Compose primeiro."
    exit 1
fi

# Verificar versão do Docker
DOCKER_VERSION=$(docker --version | grep -oE '[0-9]+\.[0-9]+' | head -1)
if [ "$(echo "$DOCKER_VERSION >= 20.0" | bc -l)" != "1" ]; then
    warn "Versão do Docker ($DOCKER_VERSION) pode ser muito antiga. Recomendado: 20.0+"
fi

# Verificar recursos do sistema
log "Verificando recursos do sistema..."

# Verificar memória
TOTAL_MEM=$(free -g | awk '/^Mem:/{print $2}')
if [ "$TOTAL_MEM" -lt 6 ]; then
    warn "Memória RAM total ($TOTAL_MEM GB) é menor que 6GB. Recomendado: 8GB+"
fi

# Verificar espaço em disco
AVAILABLE_SPACE=$(df -BG . | awk 'NR==2 {print $4}' | sed 's/G//')
if [ "$AVAILABLE_SPACE" -lt 5 ]; then
    warn "Espaço em disco disponível ($AVAILABLE_SPACE GB) é menor que 5GB."
fi

# Verificar vm.max_map_count para Elasticsearch
CURRENT_MAP_COUNT=$(sysctl -n vm.max_map_count 2>/dev/null || echo "0")
if [ "$CURRENT_MAP_COUNT" -lt 262144 ]; then
    log "Configurando vm.max_map_count para Elasticsearch..."
    sudo sysctl -w vm.max_map_count=262144
    echo 'vm.max_map_count=262144' | sudo tee -a /etc/sysctl.conf > /dev/null
fi

# Criar diretórios necessários
log "Criando estrutura de diretórios..."
mkdir -p logs/{nginx,elasticsearch,logstash,filebeat,metricbeat}
mkdir -p data/{elasticsearch,kibana}

# Configurar permissões
log "Configurando permissões..."
sudo chown -R 1000:1000 data/elasticsearch/ || true
sudo chown -R 1000:1000 data/kibana/ || true

# Iniciar serviços
log "Iniciando serviços ELK Stack..."
docker compose down --remove-orphans 2>/dev/null || true

# Pull das imagens primeiro
log "Baixando imagens Docker..."
docker compose pull

# Iniciar serviços em etapas
log "Iniciando Elasticsearch..."
docker compose up -d elasticsearch

# Aguardar Elasticsearch
log "Aguardando Elasticsearch ficar pronto..."
timeout=300
counter=0
while ! curl -s http://localhost:9200/_cluster/health > /dev/null 2>&1; do
    if [ $counter -ge $timeout ]; then
        error "Timeout aguardando Elasticsearch ficar pronto"
        exit 1
    fi
    sleep 2
    counter=$((counter + 2))
    echo -n "."
done
echo ""
log "Elasticsearch está pronto!"

# Iniciar Kibana
log "Iniciando Kibana..."
docker compose up -d kibana

# Aguardar Kibana
log "Aguardando Kibana ficar pronto..."
counter=0
while ! curl -s http://localhost:5601/api/status > /dev/null 2>&1; do
    if [ $counter -ge $timeout ]; then
        error "Timeout aguardando Kibana ficar pronto"
        exit 1
    fi
    sleep 2
    counter=$((counter + 2))
    echo -n "."
done
echo ""
log "Kibana está pronto!"

# Iniciar demais serviços
log "Iniciando Logstash, Filebeat, Metricbeat e Nginx..."
docker compose up -d

# Aguardar todos os serviços
log "Aguardando todos os serviços ficarem saudáveis..."
sleep 30

# Verificar status dos serviços
log "Verificando status dos serviços..."
docker compose ps

# Gerar alguns logs iniciais
log "Gerando logs iniciais de teste..."
sleep 10
for i in {1..10}; do
    curl -s http://localhost/ > /dev/null || true
    curl -s http://localhost/api/test > /dev/null || true
    curl -s http://localhost/health > /dev/null || true
    sleep 1
done

# Configurar index patterns no Kibana (opcional)
log "Configurando index patterns no Kibana..."
sleep 10

# Template para logstash
curl -X PUT "localhost:9200/_index_template/logstash-nginx" -H 'Content-Type: application/json' -d'{
  "index_patterns": ["logstash-nginx-*"],
  "template": {
    "settings": {
      "number_of_shards": 1,
      "number_of_replicas": 0
    },
    "mappings": {
      "properties": {
        "@timestamp": { "type": "date" },
        "remote_addr": { "type": "ip" },
        "status": { "type": "integer" },
        "request_time": { "type": "float" },
        "geoip.location": { "type": "geo_point" }
      }
    }
  }
}' 2>/dev/null || true

# Mostrar informações finais
echo ""
echo -e "${GREEN}╔══════════════════════════════════════════════════════════╗${NC}"
echo -e "${GREEN}║                    ✅ Setup Concluído!                   ║${NC}"
echo -e "${GREEN}╚══════════════════════════════════════════════════════════╝${NC}"
echo ""
echo -e "${BLUE}🌐 Interfaces Disponíveis:${NC}"
echo -e "   • Web App:        http://localhost"
echo -e "   • Kibana:         http://localhost:5601"
echo -e "   • Elasticsearch:  http://localhost:9200"
echo -e "   • Logstash Stats: http://localhost:9600"
echo ""
echo -e "${BLUE}📋 Próximos Passos:${NC}"
echo -e "   1. Acesse o Kibana em http://localhost:5601"
echo -e "   2. Configure index patterns: logstash-nginx-*, filebeat-*, metricbeat-*"
echo -e "   3. Explore os logs na aba 'Discover'"
echo -e "   4. Gere logs de teste em http://localhost"
echo -e "   5. Crie visualizações e dashboards"
echo ""
echo -e "${BLUE}🔧 Comandos Úteis:${NC}"
echo -e "   • Ver logs:       docker-compose logs -f"
echo -e "   • Status:         docker-compose ps"
echo -e "   • Parar tudo:     docker-compose down"
echo -e "   • Restart:        docker-compose restart"
echo ""
echo -e "${YELLOW}📊 Monitoramento:${NC}"
echo -e "   • Health:         curl http://localhost:9200/_cluster/health"
echo -e "   • Indices:        curl http://localhost:9200/_cat/indices?v"
echo -e "   • Stats:          curl http://localhost:9600/_node/stats"
echo ""
log "ELK Stack 2025 está pronto para uso! 🎉" 
