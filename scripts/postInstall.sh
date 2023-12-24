# set env vars
set -o allexport; source .env; set +o allexport;

echo "Waiting for software to be ready ..."
sleep 60s;

target=$(docker-compose port opnform 80)

curl http://${target}/api/register \
  -H 'accept: application/json, text/plain, */*' \
  -H 'accept-language: en' \
  -H 'cache-control: no-cache' \
  -H 'content-type: application/json' \
  -H 'pragma: no-cache' \
  -H 'user-agent: Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36' \
  --data-raw '{"name":"admin","email":"'${ADMIN_EMAIL}'","password":"'${ADMIN_PASSWORD}'","password_confirmation":"'${ADMIN_PASSWORD}'","agree_terms":true,"hear_about_us":"other"}' \
  --compressed