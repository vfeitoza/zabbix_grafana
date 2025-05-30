#!/bin/bash

# Checa se o docker foi instalado antes de tentar instalar novamente
command -v docker >/dev/null 2>&1 ||
{ echo >&2 "";
  apt update
  apt install nano curl -y
  curl -fsSL https://get.docker.com/ | sh

  # Habilita IPv6 no docker
  echo '{ "experimental": true, "ip6tables": true }' > /etc/docker/daemon.json
  systemctl restart docker
}