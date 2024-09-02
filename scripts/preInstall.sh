set env vars
set -o allexport; source .env; set +o allexport;


generate_secret() {
  LC_ALL=C tr -dc A-Za-z0-9 </dev/urandom | head -c 40 ; echo ''
}

SHARED_SECRET=$(generate_secret)

cat << EOT >> ./.env

APP_KEY=$(openssl rand -base64 32)
JWT_SECRET=$SHARED_SECRET
SHARED_SECRET=$SHARED_SECRET
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

cat <<EOT > ./nginx.conf
map \$original_uri \$api_uri {
    ~^/api(/.*$) $1;
    default \$original_uri;
}

server {
         listen       80;
         server_name  opnform;
         root         /app/public;

         access_log /dev/stdout;
         error_log  /dev/stderr error;

         index index.html index.htm index.php;

         location / {
           proxy_http_version 1.1;
           proxy_pass http://ui:3000;
           proxy_set_header X-Real-IP \$remote_addr;
           proxy_set_header X-Forwarded-Host \$host;
           proxy_set_header X-Forwarded-Port \$server_port;
           proxy_set_header Upgrade \$http_upgrade;
           proxy_set_header Connection "Upgrade";
         }

         location ~/(api|open|local\/temp|forms\/assets)/ {
              set \$original_uri \$uri;
              try_files \$uri \$uri/ /index.php\$is_args\$args;
         }

         location ~ \.php$ {
            fastcgi_split_path_info ^(.+\.php)(/.+)$;
            fastcgi_pass api:9000;
            fastcgi_index index.php;
            include fastcgi_params;
            #fastcgi_param SCRIPT_FILENAME /usr/share/nginx/html/\$fastcgi_script_name;
            fastcgi_param SCRIPT_FILENAME /usr/share/nginx/html/public/index.php;
            fastcgi_param REQUEST_URI \$api_uri;
         }
}
EOT


