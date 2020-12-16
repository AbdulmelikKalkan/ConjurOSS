#! /bin/bash

## FUNCTIONS

# Get selinux status, disabled or enabled
function selinuxStatus () {
  if [[ $(sestatus | grep 'SELinux status:' | sed '/SELinux status/ s/[^:]*: *//; s/,.*//') = *enabled* ]]; then
    echo "SELinux is enabled!"
    return 1
  else
    echo "SELinux is not enabled!"
    return 0
  fi
}

# If selinux is enabled, Modify yaml file
if selinuxStatus $1; then
  echo "disabled"
  sed -i -e "s+./conf/policy:/policy+./conf/policy:/policy:Z+g" docker-compose.yml
else
  echo "disabled"
fi

# Pull docker image
docker-compose pull

# Generate the master key
docker-compose run --no-deps --rm conjur data-key generate > data_key

# Load master key as an environment variable
export CONJUR_DATA_KEY="$(< data_key)"
echo CONJUR_DATA_KEY="$(< data_key)" >> /etc/environment
# Start the Conjur OSS environment
docker-compose up -d
sleep 3
# Create Admin Account
docker-compose exec conjur conjurctl account create myConjurAccount > admin_data

# Connect the conjur client to the conjur server
docker-compose exec client conjur init -u conjur -a myConjurAccount

# Log in to conjur as admin
admin_key=$(cat admin_data | grep API | sed '/admin/ s/[^:]*: *//; s/,.*//' | tr -d '\r')
echo $admin_key
docker-compose exec client conjur authn login -u admin -p $admin_key

# Load the sample policy
docker-compose exec client conjur policy load root policy/BotApp.yml > my_app_data

# Log out of conjur
docker-compose exec client conjur authn logout



#      ## with Dave@BotApp api key
#      sudo docker-compose exec client conjur authn login -u Dave@BotApp
#      sudo docker-compose exec client conjur authn whoami
#      secretVal=$(openssl rand -hex 12 | tr -d '\r\n')
#      docker-compose exec client conjur variable values add BotApp/secretVar ${secretVal}