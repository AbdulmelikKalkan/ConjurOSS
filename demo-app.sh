#! /bin/bash

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
#secretVal=$(openssl rand -hex 12 | tr -d '\r\n')
secretVal="Abdulmelik Kalkan"
echo $secretVal
# Store the secret
docker-compose exec -T client conjur variable values add BotApp/secretVar "${secretVal}"

# Get BotApp Key
botApp_key=$(cat my_app_data | jq '.created_roles[] | .api_key' | sed -n 2p | sed 's/"//g' | tr -d '\r')
echo $botApp_key

# Set proxy ip to host file
proxy=$(docker inspect -f '{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}' nginx_proxy) &
echo "$proxy proxy" >> /etc/hosts


# Start a bash session
docker exec -T bot_app bash

# Generate a conjur token
curl -d $botApp_key -k https://proxy/authn/myConjurAccount/host%2FBotApp%2FmyDemoApp/authenticate > /tmp/conjur_token


# Fetch a secret
/bin/sh /home/vagrant/conjur-quickstart/program.sh