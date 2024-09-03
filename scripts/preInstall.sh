set env vars
set -o allexport; source .env; set +o allexport;

mkdir -p ./opnform
mkdir -p ./opnform/opnform_storage
chmod -R 777 ./opnform/opnform_storage

cat /opt/elestio/startPostfix.sh > post.txt
filename="./post.txt"

SMTP_LOGIN=""
SMTP_PASSWORD=""

# Read the file line by line
while IFS= read -r line; do
  # Extract the values after the flags (-e)
  values=$(echo "$line" | grep -o '\-e [^ ]*' | sed 's/-e //')

  # Loop through each value and store in respective variables
  while IFS= read -r value; do
    if [[ $value == RELAYHOST_USERNAME=* ]]; then
      SMTP_LOGIN=${value#*=}
    elif [[ $value == RELAYHOST_PASSWORD=* ]]; then
      SMTP_PASSWORD=${value#*=}
    fi
  done <<< "$values"

done < "$filename"

rm post.txt

generate_secret() {
  LC_ALL=C tr -dc A-Za-z0-9 </dev/urandom | head -c 40 ; echo ''
}

SHARED_SECRET=$(generate_secret)

cat << EOT >> ./.env
MAIL_PASSWORD=$SMTP_PASSWORD
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
