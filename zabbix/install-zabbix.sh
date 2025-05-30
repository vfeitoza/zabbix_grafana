#!/bin/bash

cat <<EOF

@
@

INSTALAÇÃO DO ZABBIX INICIADA!

Após responder as perguntas a seguir pode levantar e ir pegar um café que a instalação demora...

Não se esqueça de remover este script ao finalizar

@
@

EOF

read -p "Informe o nome da empresa ou um nome para o server: " nomeZabbix

read -p "Informe o domínio completo caso tenha sido feito apontamento (zabbix.empresa.com): " proxy

# Verifica se o compose esta instalado
./install-compose.sh 

# Baixa arquivos do zabbix
git clone https://github.com/zabbix/zabbix-docker.git /root/zabbix-docker

# Entrando na pasta
cd /root/zabbix-docker

# Altera paramentros do zabbix
sed -i "s/ZBX_SERVER_NAME=Composed installation/ZBX_SERVER_NAME=$nomeZabbix/g" env_vars/.env_web
sed -i "s/# PHP_TZ=Europe\/Riga/PHP_TZ=America\/Sao_Paulo/g" env_vars/.env_web

sed -i "s/# ZBX_CACHESIZE=8M/ZBX_CACHESIZE=128M/g" env_vars/.env_srv
sed -i "s/# ZBX_TIMEOUT=4/ZBX_TIMEOUT=30/g" env_vars/.env_srv
sed -i "s/# ZBX_STARTPOLLERS=5/ZBX_STARTPOLLERS=30/g" env_vars/.env_srv
sed -i "s/# ZBX_STARTPREPROCESSORS=3/ZBX_STARTPREPROCESSORS=5/g" env_vars/.env_srv
sed -i "s/# ZBX_STARTPOLLERSUNREACHABLE=1/ZBX_STARTPOLLERSUNREACHABLE=5/g" env_vars/.env_srv
sed -i "s/# ZBX_STARTHISTORYPOLLERS=5/ZBX_STARTHISTORYPOLLERS=10/g" env_vars/.env_srv
sed -i "s/# ZBX_STARTPINGERS=1/ZBX_STARTPINGERS=5/g" env_vars/.env_srv
sed -i "s/# ZBX_STARTDISCOVERERS=5/ZBX_STARTDISCOVERERS=5/g" env_vars/.env_srv
sed -i "s/# ZBX_HOUSEKEEPINGFREQUENCY=1/ZBX_HOUSEKEEPINGFREQUENCY=1/g" env_vars/.env_srv
sed -i "s/# ZBX_MAXHOUSEKEEPERDELETE=5000/ZBX_MAXHOUSEKEEPERDELETE=10000/g" env_vars/.env_srv
sed -i "s/# ZBX_HISTORYCACHESIZE=16M/ZBX_HISTORYCACHESIZE=128M/g" env_vars/.env_srv

# Copia o executavel do zabbix-in-telegram para dentro da pasta do container
cp /root/scripts/zabbix/install-telegram.sh /root/zabbix-docker/Dockerfiles/server-mysql/ubuntu/

# Copia os arquivos de instalação do zabbix-in-telegram para dentro do container
awk '/apt-get -y clean/ { print "    apt-get -y clean\n\n#Zabbix in Telegram\nCOPY [\"install-telegram.sh\", \"/opt/install-telegram.sh\"]\nRUN chmod +x /opt/install-telegram.sh && /opt/install-telegram.sh"; next }1' /root/zabbix-docker/Dockerfiles/server-mysql/ubuntu/Dockerfile > /tmp/Dockerfile.tmp
mv /tmp/Dockerfile.tmp /root/zabbix-docker/Dockerfiles/server-mysql/ubuntu/Dockerfile

# Instala o zabbix e o zabbix-agent
docker compose -f docker-compose_v3_ubuntu_mysql_local.yaml up -d --build
docker compose -f docker-compose_v3_ubuntu_mysql_local.yaml up -d zabbix-agent --build

#docker compose -f docker-compose_v3_ubuntu_mysql_local.yaml down -v zabbix-agent

# Copia scripts para o container
cp /root/scripts/zabbix/externalscripts/* /root/zabbix-docker/zbx_env/usr/lib/zabbix/externalscripts/

git clone https://github.com/ableev/Zabbix-in-Telegram.git /root/zabbix-docker/zbx_env/usr/lib/zabbix/alertscripts/

cp /root/scripts/zabbix/alertscripts/* /root/zabbix-docker/zbx_env/usr/lib/zabbix/alertscripts/

# Altera senha da API
senhaAPI=`openssl rand -base64 32 | tr -d "/[:space:]"`
sed -i "s/zbx_api_pass = \"api\"/zbx_api_pass = \"$senhaAPI\"/g" /root/zabbix-docker/zbx_env/usr/lib/zabbix/alertscripts/zbxtg_settings.py

cat <<EOF

@
@

A INSTALAÇÃO CLI DO ZABBIX ESTÁ QUASE FINALIZADA!

Por favor crie o grupo do Telegram e informe o nome do grupo abaixo
(este nome pode ser alterado depois em Users > Users > api > Media)

@
@

EOF

echo " "
read -p "Informe o nome do grupo do telegram ou deixe vazio caso queira fazer manualmente: " grupoTelegram

imp_templates=0
# Deseja realizar a importacao dos templates ?
echo "Realizar a importação dos templates padrões?"
select yn in "Sim" "Nao"; do
    case $yn in
        Sim ) imp_templates=1;
            break;;
        Nao )
            break;;
    esac
done

imp_hosts=0
# Deseja realizar a importacao dos hosts ?
echo "Realizar a importação dos hosts padrões?"
select yn in "Sim" "Nao"; do
    case $yn in
        Sim ) imp_hosts=1;
            break;;
        Nao )
            break;;
    esac
done

if [[ -z "$grupoTelegram" ]] then # SE NÃO INFORMAR O GRUPO, SETA COMO ZABBIX
    grupoTelegram="Zabbix"
fi

if [[ "$grupoTelegram" != "Zabbix" || $imp_templates != 0 || $imp_hosts != 0 ]] then # EXECUTA O SCRIPT SOMENTE SE O USUÁRIO INFORMAR AS INFOS ACIMA
    echo "Aguardando o processo do zabbix subir..."
    sleep 5
    python3 /root/scripts/zabbix/import-zabbix.py --apipass "$senhaAPI" --telegram "$grupoTelegram" --templates $imp_templates --hosts $imp_hosts --debug
fi

if [[ -n "$proxy" ]] then # CONECTA NA NETWORK CASO TENHA PROXY
    docker network connect reverse-proxy_proxy-hexa zabbix-docker-zabbix-web-nginx-mysql-1 --alias zabbix-docker-zabbix-web-nginx-mysql-1 --alias zabbix-web-nginx-mysql

    docker restart reverse
else # LISTA OS IPS CASO NÃO SEJA PROXY
    ips=$(hostname -I)
    for word in $ips
    do
        if [[ "$word" != "172."* ]] then
            if [[ "$word" == *":"* ]] then
                lista="http://[$word]/"$'\n'"$lista"
            else
                lista="http://$word/"$'\n'"$lista"
            fi
        fi
    done
fi

cat <<EOF

@
@

INSTALAÇÃO CLI DO ZABBIX FINALIZADA!

Finalize a instalação WEB em um dos links abaixo (Admin/zabbix):
$lista
Inserir "^<pppoe" na expressão regular
Não se esqueça de enviar o comando abaixo no grupo do telegram:
/start@MonitoramentoBOT

Não se esqueça de remover este script ao finalizar

@
@

EOF
