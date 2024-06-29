#!/bin/bash

# Caminho para o arquivo SQL
sql_script="RODEAQUI.sql"

# Executa o script SQL usando psql
sudo -u postgres -d airbnb2 -f "$sql_script"
