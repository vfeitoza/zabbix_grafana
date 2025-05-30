#!/bin/bash

cat <<EOF

@
@

INSTALAÇÃO DO GRAFANA INICIADA!

Aguarde, a instalação não deve demorar muito...

Não se esqueça de remover este script ao finalizar

@
@

EOF

read -p "Informe o domínio completo caso tenha sido feito apontamento (zabbix.empresa.com): " proxy

# Verifica se o compose esta instalado
./install-compose.sh 

# Cria diretório do grafana
mkdir /root/grafana-docker

# Entra no diretório do grafana para criar o docker-compose
cd /root/grafana-docker

lista=""
ports=""
network_proxy=" - reverse-proxy_proxy-hexa"
network_proxy_external="reverse-proxy_proxy-hexa:
    external: true"
if [[ -z "$proxy" ]] then
    ports="ports:
    - '3000:3000'"

    network_proxy=""
    network_proxy_external=""
fi

# Criando arquivo docker-compose
cat > docker-compose.yaml <<EOF
services:
  grafana:
    image: grafana/grafana-enterprise
    container_name: grafana
    restart: unless-stopped
    environment:
     - GF_INSTALL_PLUGINS=alexanderzobnin-zabbix-app
    $ports
    networks:
     - zabbix-docker_frontend
    $network_proxy
    volumes:
     - 'grafana_storage:/var/lib/grafana'

networks:
  zabbix-docker_frontend:
    external: true
  $network_proxy_external

volumes:
  grafana_storage: {}
EOF

# Baixando containers
docker compose up -d

if [[ -z "$proxy" ]] then
    ips=$(hostname -I)
    for word in $ips
    do
        if [[ "$word" != "172."* ]] then
            if [[ "$word" == *":"* ]] then
                lista="http://[$word]:3000"$'\n'"$lista"
            else
                lista="http://$word:3000"$'\n'"$lista"
            fi
        fi
    done
fi

cat <<EOF

@
@

INSTALAÇÃO CLI DO GRAFANA FINALIZADA!

Altere a senha do usuário admin no link abaixo (admin/grafana)
$lista


Após finalizar a instalação web, habilite o plugin do Zabbix e configure ele:
1- Ir em Administration > plugins no lado esquerdo. Procurar por Zabbix na barra de pesquisa. E clicar em ENABLE.

2- Ir em Connections no lado esquerdo. Data Sources. Procurar por Zabbix. Alterar:
    Connection:
         http://zabbix-web-nginx-mysql:8080/api_jsonrpc.php

    Zabbix Connection:
         Login e senha do Zabbix

Não se esqueça de remover este script ao finalizar

@
@

EOF
