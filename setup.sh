#! /bin/bash

## FUNCTIONS

# Get selinux status, disabled or enabled
function selinuxStatus () {
  if [[ $(sestatus | grep 'SELinux status:' | sed '/SELinux status/ s/[^:]*: *//; s/,.*//') = *enabled* ]]; then
    echo "SELinux is enabled!"
    return 0
  else
    echo "SELinux is not enabled!"
    return 1
  fi
}

# If selinux is enabled, Modify yaml file
if selinuxStatus $1; then
  sed -i -e "s+./conf/policy:/policy+./conf/policy:/policy:Z+g" docker-compose.yml
  echo "docker-compose.yml is modified!"
fi

# Pull docker image
echo "Pull docker image"
docker-compose pull

# Generate the master key
echo "Generate the master key"
docker-compose run --no-deps --rm conjur data-key generate > data_key

# Load master key as an environment variable
echo "Load master key as an environment variable"
export CONJUR_DATA_KEY="$(< data_key)"
echo CONJUR_DATA_KEY="$(< data_key)" >> /etc/environment
# Start the Conjur OSS environment
echo "Start the Conjur OSS environment"
docker-compose up -d & pid=$!
wait $pid
sleep 10
echo "Completed docker-compose up!"
# Create Admin Account
##echo "Create Admin Account"
docker-compose exec -T conjur conjurctl account create myConjurAccount > admin_data

# Connect the conjur client to the conjur server
#echo "Connect the conjur client to the conjur server"
docker-compose exec -T client conjur init -u conjur -a myConjurAccount

# Log in to conjur as admin
#echo "Log in to conjur as admin"
admin_key=$(cat admin_data | grep API | sed '/admin/ s/[^:]*: *//; s/,.*//' | tr -d '\r')
echo $admin_key
docker-compose exec -T client conjur authn login -u admin -p $admin_key

# Load the sample policy
#echo "Load the sample policy"
docker-compose exec -T client conjur policy load root policy/BotApp.yml > my_app_data

# Log out of conjur
#echo "Log out of conjur"
docker-compose exec -T client conjur authn logout

# Log in as Dave
dave_key=$(cat my_app_data | jq '.created_roles[] | .api_key' | sed -n 1p | sed 's/"//g' | tr -d '\r')
echo $dave_key
docker-compose exec -T client conjur authn login -u Dave@BotApp -p $dave_key

# Verification
docker-compose exec -T client conjur authn whoami

# Generate a secret
secretVal=$(openssl rand -hex 12 | tr -d '\r\n')
echo $secretVal
# Store the secret
docker-compose exec -T client conjur variable values add BotApp/secretVar ${secretVal}

# Get BotApp Key
botApp_key=$(cat my_app_data | jq '.created_roles[] | .api_key' | sed -n 2p | sed 's/"//g' | tr -d '\r')
echo $botApp_key

# Start a bash session
#docker exec -T bot_app bash

# Generate a conjur token
#curl -d $botApp_key -k https://proxy/authn/myConjurAccount/host%2FBotApp%2FmyDemoApp/authenticate > /tmp/conjur_token

# Fetch a secret
#/bin/sh /tmp/program.sh

#      ## with Dave@BotApp api key
#      sudo docker-compose exec client conjur authn login -u Dave@BotApp
#      sudo docker-compose exec client conjur authn whoami
#      secretVal=$(openssl rand -hex 12 | tr -d '\r\n')
#      docker-compose exec client conjur variable values add BotApp/secretVar ${secretVal}