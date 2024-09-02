set env vars
set -o allexport; source .env; set +o allexport;


generate_secret() {
  LC_ALL=C tr -dc A-Za-z0-9 </dev/urandom | head -c 40 ; echo ''
}

SHARED_SECRET=$(generate_secret)

cat << EOT >> ./.env

APP_KEY=base64:$(openssl rand -base64 32)
JWT_SECRET=$(generate_secret)
NUXT_API_SECRET=$SHARED_SECRET
FRONT_API_SECRET=$SHARED_SECRET
EOT

cat <<EOT > ./servers.json
{
    "Servers": {
        "1": {
            "Name": "local",
            "Group": "Servers",
            "Host": "172.17.0.1",
            "Port": 27779,
            "MaintenanceDB": "postgres",
            "SSLMode": "prefer",
            "Username": "postgres",
            "PassFile": "/pgpass"
        }
    }
}
EOT
