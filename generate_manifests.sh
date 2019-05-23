vault_url=$1
role_id=$2
secret_id=$3
environment=$4
namespace=$5

client_token=$(curl -s -d "{\"role_id\":\"$role_id\", \"secret_id\":\"$secret_id\"}" -H "Content-Type: application/json" -X POST $vault_url/v1/auth/approle/login | jq -r '.auth.client_token')

secrets=$(curl -s -H "x-vault-token: ${client_token}" GET $vault_url/v1/kv/data/$environment/rabbit)

username=$(echo $secrets | jq -r '.data.data.USERNAME')
password=$(echo $secrets | jq -r '.data.data.PASSWORD')
management_username=$(echo $secrets | jq -r '.data.data.MANAGEMENT_USERNAME')
management_password=$(echo $secrets | jq -r '.data.data.MANAGEMENT_PASSWORD')
erlang_cookie=$(echo $secrets | jq -r '.data.data.ERLANG_COOKIE')

mkdir -p manifests

helm template --output-dir manifests --namespace $namespace --set rabbitmqUsername=$username,rabbitmqPassword=$password,managementUsername=$management_username,managementPassword=$management_password,rabbitmqErlangCookie=$erlang_cookie,fullnameOverride=crds-rabbit  helm-chart/