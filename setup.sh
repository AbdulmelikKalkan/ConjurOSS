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
