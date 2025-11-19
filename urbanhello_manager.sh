#!/bin/bash

# ===== CONFIGURATION =====
USERNAME="ACCOUNT_USER_MAIL"
PASSWORD="ACCOUNT_PASSWORD"
TOKEN_FILE="/var/www/html/plugins/script/data/urbanhello/.urbanhello_token"
USER_OBJECT_ID_FILE="/var/www/html/plugins/script/data/urbanhello/.urbanhello_user_object_id"

# ===== FONCTIONS CORE =====
login() {
    echo "Tentative de connexion à UrbanHello..."
    response=$(python3 /var/www/html/plugins/script/data/urbanhello/urbanhello_api.py login "$USERNAME" "$PASSWORD")
    token=$(echo "$response" | jq -r '.sessionToken')
    user_object_id=$(echo "$response" | jq -r '.objectId')
    echo "Token extrait: $token"
    echo "User Object ID: $user_object_id"

    if [[ -z "$token" || "$token" == "null" ]]; then
        echo "Échec de connexion. Réponse API:"
        echo "$response" | jq
        exit 1
    fi

    echo "$token" > "$TOKEN_FILE"
    echo "$user_object_id" > "$USER_OBJECT_ID_FILE"
    echo "Connexion réussie."
}

get_user_info() {
    if [[ ! -f "$TOKEN_FILE" || ! -f "$USER_OBJECT_ID_FILE" ]]; then
        login
    fi
    token=$(cat "$TOKEN_FILE")
    user_object_id=$(cat "$USER_OBJECT_ID_FILE")

    if [[ -n "$1" ]]; then
        user_info=$(python3 /var/www/html/plugins/script/data/urbanhello/urbanhello_api.py user_info "$token" "$user_object_id" "$1")
        echo "$user_info" | jq -r
    else
        user_info=$(python3 /var/www/html/plugins/script/data/urbanhello/urbanhello_api.py user_info "$token" "$user_object_id")
        echo "$user_info" | jq
    fi
}

get_remi_info() {
    if [[ ! -f "$TOKEN_FILE" ]]; then
        login
    fi
    token=$(cat "$TOKEN_FILE")

    if [[ -n "$2" ]]; then
        remi_info=$(python3 /var/www/html/plugins/script/data/urbanhello/urbanhello_api.py remi_info "$token" "$1" "$2")
        echo "$remi_info" | jq -r
    else
        remi_info=$(python3 /var/www/html/plugins/script/data/urbanhello/urbanhello_api.py remi_info "$token" "$1")
        echo "$remi_info" | jq
    fi
}

set_luminosity() {
    if [[ ! -f "$TOKEN_FILE" ]]; then login; fi
    token=$(cat "$TOKEN_FILE")
    result=$(python3 /var/www/html/plugins/script/data/urbanhello/urbanhello_api.py set_luminosity "$token" "$1" "$2")
    echo "$result" | jq
}

set_face_expression() {
    if [[ ! -f "$TOKEN_FILE" ]]; then login; fi
    token=$(cat "$TOKEN_FILE")
    result=$(python3 /var/www/html/plugins/script/data/urbanhello/urbanhello_api.py set_face_expression "$token" "$1" "$2")
    echo "$result" | jq
}

get_alarms() {
    if [[ ! -f "$TOKEN_FILE" ]]; then login; fi
    token=$(cat "$TOKEN_FILE")
    alarms=$(python3 /var/www/html/plugins/script/data/urbanhello/urbanhello_api.py get_alarms "$token" "$1")
    echo "$alarms" | jq
}

get_temperature() {
    if [[ ! -f "$TOKEN_FILE" ]]; then login; fi
    token=$(cat "$TOKEN_FILE")
    temp=$(python3 /var/www/html/plugins/script/data/urbanhello/urbanhello_api.py get_temperature "$token" "$1")
    echo "$temp" | jq -r
}

get_all_info() {
    if [[ ! -f "$TOKEN_FILE" || ! -f "$USER_OBJECT_ID_FILE" ]]; then login; fi
    token=$(cat "$TOKEN_FILE")
    user_object_id=$(cat "$USER_OBJECT_ID_FILE")
    user_info=$(python3 /var/www/html/plugins/script/data/urbanhello/urbanhello_api.py user_info "$token" "$user_object_id")

    echo "=== Informations de l'utilisateur ==="
    echo "$user_info" | jq

    remis=$(echo "$user_info" | jq -r '.remis[]')
    for remi_id in $remis; do
        echo "=== Réveil ID: $remi_id ==="
        remi_info=$(python3 /var/www/html/plugins/script/data/urbanhello/urbanhello_api.py remi_info "$token" "$remi_id")
        echo "$remi_info" | jq
        alarms=$(python3 /var/www/html/plugins/script/data/urbanhello/urbanhello_api.py get_alarms "$token" "$remi_id")
        echo "Alarmes pour Réveil ID: $remi_id"
        echo "$alarms" | jq
    done
}

list_alarms() {
    if [[ ! -f "$TOKEN_FILE" ]]; then login; fi
    token=$(cat "$TOKEN_FILE")
    alarms=$(python3 /var/www/html/plugins/script/data/urbanhello/urbanhello_api.py alarms "$token" "$1")
    echo "$alarms" | jq
}

set_alarm() {
    if [[ ! -f "$TOKEN_FILE" ]]; then login; fi
    token=$(cat "$TOKEN_FILE")
    result=$(python3 /var/www/html/plugins/script/data/urbanhello/urbanhello_api.py set_alarm "$token" "$1" "$2" "$3" "$4")
    echo "$result" | jq
}


# ============================
#     NOUVELLES COMMANDES FACE
# ============================

get_face() {
    if [[ ! -f "$TOKEN_FILE" ]]; then login; fi
    token=$(cat "$TOKEN_FILE")
    face=$(python3 /var/www/html/plugins/script/data/urbanhello/urbanhello_api.py get_face "$token" "$1")
    echo "$face"
}

set_face() {
    if [[ ! -f "$TOKEN_FILE" ]]; then login; fi
    token=$(cat "$TOKEN_FILE")
    result=$(python3 /var/www/html/plugins/script/data/urbanhello/urbanhello_api.py set_face "$token" "$1" "$2")
    echo "$result" | jq
}

# ============================
#     DISPATCHER ARGUMENTS
# ============================

if [[ $# -eq 0 ]]; then
    get_all_info
    exit 0
fi

case $1 in
    account)
        get_user_info "$2"
        ;;
    remi)
        get_remi_info "$2" "$3"
        ;;
    set_luminosity)
        set_luminosity "$2" "$3"
        ;;
    set_face_expression)
        set_face_expression "$2" "$3"
        ;;
    get_alarms)
        get_alarms "$2"
        ;;
    get_temp)
        get_temperature "$2"
        ;;
    alarms)
        list_alarms "$2"
        ;;
    set_alarm)
        set_alarm "$2" "$3" "$4" "$5"
        ;;
    face)
        if [[ -n "$3" ]]; then
            set_face "$2" "$3"
        else
            get_face "$2"
        fi
        ;;
    *)
        echo "Usage: $0 [...]"
        exit 1
        ;;
esac
