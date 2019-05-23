role_id=$1
secret_id=$2
environment=$3

client_token=$(curl -s -d "{\"role_id\":\"$role_id\", \"secret_id\":\"$secret_id\"}" -H "Content-Type: application/json" -X POST https://vault.crossroads.net/v1/auth/approle/login | jq -r '.auth.client_token')

secrets=$(curl -s -H "x-vault-token: ${client_token}" GET https://vault.crossroads.net/v1/kv/data/$environment/rabbit)

username=$(echo $secrets | jq -r '.data.data.USERNAME')
password=$(echo $secrets | jq -r '.data.data.PASSWORD')
management_username=$(echo $secrets | jq -r '.data.data.MANAGEMENT_USERNAME')
management_password=$(echo $secrets | jq -r '.data.data.MANAGEMENT_PASSWORD')
erlang_cookie=$(echo $secrets | jq -r '.data.data.ERLANG_COOKIE')

echo $username

mkdir -p manifests

helm template --output-dir manifests --set rabbitmqUsername=$username,rabbitmqPassword=$password,managementUsername=$management_username,managementPassword=$management_password,rabbitmqErlangCookie=$erlang_cookie,fullnameOverride=crds-rabbit  helm-chart/