#!/usr/bin/env python3
# coding: utf-8

import sys
import os
import time
import requests
import json


class ZabbixWeb:
    def __init__(self, server, username, password):
        self.debug = False
        self.server = server
        self.username = username
        self.password = password
        self.verify = False
        self.headers = { 'Content-Type': 'application/json-rpc' }
        self.count = 1

    def login(self):
        if not self.verify:
            requests.packages.urllib3.disable_warnings()

        # Faz o login no zabbix e gera o token para ser utilizado pelo script mais tarde como autenticação
        api_data = json.dumps({"jsonrpc": "2.0", "method": "user.login", "params":{"username": self.username, "password": self.password}, "id": self.count})
        response = requests.post(self.server, headers=self.headers, data=api_data, verify=self.verify)

        data = response.json()

        if self.debug or "error" in data:
            print_message(data)

        if "result" in data:
            self.headers["Authorization"] = "Bearer " + data["result"]

    def updateHostInterface(self):
        self.count+=1
        # Busca o ID da hostinterface cujo IP seja 127.0.0.1
        api_data = json.dumps({"jsonrpc": "2.0", "method": "hostinterface.get", "params":
                                {
                                    "output": "shorten",
                                    "filter": {"ip": "127.0.0.1"}
                                },
                                "id": self.count})

        response = requests.post(self.server, headers=self.headers, data=api_data, verify=self.verify)

        data = response.json()

        hostInterface = None
        resultado = None

        if self.debug or "error" in data:
            print_message(data)

        if "result" in data:# Se encontrar o ID continua
            self.count+=1
            hostInterface = data["result"][0]["interfaceid"]

            # Atualiza a hostinterface para utilizar "zabbix-agent" ao invés do IP
            api_data = json.dumps({"jsonrpc": "2.0", "method": "hostinterface.update", "params":
                                {
                                    "interfaceid": hostInterface,
                                    "dns": "zabbix-agent",
                                    "useip": 0
                                },
                                "id": self.count})

            response = requests.post(self.server, headers=self.headers, data=api_data, verify=self.verify)

            data = response.json()

            if self.debug or "error" in data:
                print_message(data)

            if "result" in data:
                resultado = data["result"]

        return resultado

    def createUser(self, api_pass, grupo_telegram):
        self.count+=1
        resultado = None

        # Busca o ID do Media type a ser usado
        api_data = json.dumps({"jsonrpc": "2.0", "method": "mediatype.get", "params":
                                {
                                    "output": ["mediatypeid"],
                                    "filter": {
                                        "name": "Telegram Graph"
                                    }
                                },
                                "id": self.count})
        response = requests.post(self.server, headers=self.headers, data=api_data, verify=self.verify)

        data = response.json()

        if self.debug or "error" in data:
            print_message(data)

        if "result" in data:# Se encontrar o ID continua
            self.count+=1
            mediatypeid = data["result"][0]["mediatypeid"]
            api_data = json.dumps({"jsonrpc": "2.0", "method": "user.create", "params":
                                    {
                                        "username": "api",
                                        "passwd": api_pass,
                                        "roleid": "3",
                                        "usrgrps": [
                                            {
                                                "usrgrpid": "7"
                                            }
                                        ],
                                        "medias": [
                                            {
                                                "mediatypeid": mediatypeid,
                                                "sendto": [
                                                    grupo_telegram
                                                ],
                                                "active": 0 if grupo_telegram != "Zabbix" else 1,
                                                "severity": 63,
                                                "period": "1-7,00:00-24:00"
                                            }
                                        ]
                                    },
                                    "id": self.count})

            response = requests.post(self.server, headers=self.headers, data=api_data, verify=self.verify)

            data = response.json()

            if self.debug or "error" in data:
                print_message(data)

            if "result" in data:
                resultado = data["result"]

        return resultado

    def createTriggerAction(self, userid):
        self.count+=1
        api_data = json.dumps({"jsonrpc": "2.0", "method": "action.create", "params":
                                {
                                    "name": "Telegram Graph Notification",
                                    "eventsource": 0,
                                    "esc_period": "1h",
                                    "operations": [
                                        {
                                            "operationtype": 0,
                                            "esc_step_from": 1,
                                            "esc_step_to": 1,
                                            "opmessage_usr": [
                                                {
                                                    "userid": userid
                                                }
                                            ],
                                            "opmessage": {
                                                "default_msg": 1
                                            }
                                        }
                                    ],
                                    "recovery_operations": [
                                        {
                                            "operationtype": "11",
                                            "opmessage": {
                                                "default_msg": 1
                                            }
                                        }
                                    ]
                                },
                                "id": self.count})

        response = requests.post(self.server, headers=self.headers, data=api_data, verify=self.verify)

        data = response.json()

        resultado = None

        if self.debug or "error" in data:
            print_message(data)

        if "result" in data:
            resultado = data["result"]

        return resultado

    def importData(self, types, source):
        self.count+=1

        defRule = { "createMissing": True, "updateExisting": True }
        rules = {}

        for type in types:
            rules.update({type : defRule})

        api_data = json.dumps({"jsonrpc": "2.0", "method": "configuration.import", "params":
                                {
                                    "format": "xml",
                                    "rules":
                                        rules,
                                    "source": source
                                },
                                "id": self.count})

        response = requests.post(self.server, headers=self.headers, data=api_data, verify=self.verify)

        data = response.json()

        resultado = None

        if self.debug or "error" in data:
            print_message(data)

        if "result" in data:
            resultado = data["result"]

        return resultado


def print_message(message):
    message = str(message) + "\n"
    filename = sys.argv[0].split("/")[-1]
    sys.stderr.write(filename + ": " + message)


def file_read(filename):
    with open(filename, "r") as fd:
        text = fd.read()
    return text


def main():

    # Parametros a serem utilizados para conexão com o zabbix via host
    zbx_server = "http://127.0.0.1/api_jsonrpc.php"
    zbx_user = "Admin"
    zbx_pass = "zabbix"
    zbx_api_pass = None
    zbx_grupo_telegram = "Zabbix"
    zbx_imp_templates = False
    zbx_imp_hosts = False

    zbx = ZabbixWeb(server=zbx_server, username=zbx_user, password=zbx_pass)

    args = sys.argv

    #print_message(args)

    if "--debug" in args:
        zbx.debug = True

    if "--apipass" in args:# Senha do usuário API
        zbx_api_pass = args[args.index("--apipass") + 1]

    if "--telegram" in args:# Nome do grupo do Telegram
        zbx_grupo_telegram = args[args.index("--telegram") + 1]

    if "--templates" in args:# Importar tamplates padrões do zabbix
        zbx_imp_templates = (args[args.index("--templates") + 1] == "1")

    if "--hosts" in args:# Importar hosts padrões do zabbix
        zbx_imp_hosts = (args[args.index("--hosts") + 1] == "1")

    if "--proxy" in args:# Utilizar proxy
        zbx_server = "http://" + args[args.index("--proxy") + 1] + "/api_jsonrpc.php"

    # Tenta logar 5x pois o zabbix web demora alguns segundos para iniciar
    for x in range(5):
        time.sleep(2)
        zbx.login()

        if "Authorization" in zbx.headers:
            break

    if "Authorization" not in zbx.headers:
        print_message("Login to Zabbix web UI has failed (web url, user or password are incorrect)")
    else:
        # Atualiza o host "zabbix server" com o hostname correto (zabbix-agent)
        zbx.updateHostInterface()

        if zbx_grupo_telegram != "Zabbix":
            # Tenta inserir o mediaType e se não conseguir para por aqui
            if zbx.importData(["mediaTypes"], file_read("/root/scripts/zabbix/imports/mediaTypes.xml")):
                # Insere o usuário API e os grupos de template
                userids = zbx.createUser(zbx_api_pass, zbx_grupo_telegram)

                # Insere a Trigger Action para enviar as mensagens para o Telegram
                zbx.createTriggerAction(userids["userids"][0])

                if zbx_imp_templates:
                    zbx.importData(["template_groups", "host_groups"], file_read("/root/scripts/zabbix/imports/groups.xml"))

                    # Para cada vendor dentro de templates, adiciona ele no zabbix
                    for filename in os.listdir("/root/scripts/zabbix/imports/templates"):
                        zbx.importData(["templates", "template_groups", "mediaTypes", "graphs", "items", "triggers", "valueMaps", "discoveryRules"], file_read("/root/scripts/zabbix/imports/templates/" + filename))

                if zbx_imp_hosts:
                    zbx.importData(["hosts"], file_read("/root/scripts/zabbix/imports/hosts_conteudos.xml"))


if __name__ == "__main__":
    main()