# -*- coding: utf-8 -*-

tg_key = "794393722:AAE4ynfQ4festqB9eYRZCZ16Ul1EXasIjD4"  # telegram bot api key

zbx_tg_prefix = "zbxtg"  # variable for separating text from script info
zbx_tg_tmp_dir = "/var/tmp/" + zbx_tg_prefix  # directory for saving caches, uids, cookies, etc.
zbx_tg_signature = False

zbx_tg_update_messages = True
zbx_tg_matches = {
    "problem": "PROBLEM: ",
    "ok": "OK: "
}

zbx_server = "http://zabbix-web-nginx-mysql:8080/"  # zabbix server full url
zbx_api_user = "api"
zbx_api_pass = "api"
zbx_api_verify = False  # True - do not ignore self signed certificates, False - ignore

#zbx_server_version = 2  # for Zabbix 2.x version
zbx_server_version = 7  # for Zabbix 3.x version, by default, not everyone updated to 4.x yet
#zbx_server_version = 4  # for Zabbix 4.x version, default will be changed in the future with this

zbx_basic_auth = False
zbx_basic_auth_user = "zabbix"
zbx_basic_auth_pass = "zabbix"

proxy_to_zbx = None
proxy_to_tg = None

# proxy_to_zbx = "http://proxy.local:3128"
# proxy_to_tg = "https://proxy.local:3128"

# proxy_to_tg = "socks5://user1:password2@hostname:port" # socks5 with username and password
# proxy_to_tg = "socks5://hostname:port" # socks5 without username and password
# proxy_to_tg = "socks5h://hostname:port" # hostname resolution on SOCKS proxy.
                                          # This helps when internet provider alter DNS queries.
                                          # Found here: https://stackoverflow.com/a/43266186/957508

google_maps_api_key = None  # get your key, see https://developers.google.com/maps/documentation/geocoding/intro

zbx_tg_daemon_enabled = False
zbx_tg_daemon_enabled_ids = [6931850, ]
zbx_tg_daemon_enabled_users = ["ableev", ]
zbx_tg_daemon_enabled_chats = ["Zabbix in Telegram Script", ]

zbx_db_host = "localhost"
zbx_db_database = "zabbix"
zbx_db_user = "zbxtg"
zbx_db_password = "zbxtg"


emoji_map = {
"OK": "✅",
"Problem": "❗",
"Information": "ℹ️",
"Warning": "⚠️",
"Disaster": "❌"
}
