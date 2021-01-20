#! /bin/bash



#To create an account in Conjur
docker-compose exec -T conjur conjurctl account create ansible | tee ansible.out


#Connect the conjur client to the conjur server
docker-compose exec -T client bash -c "echo yes | conjur init -u conjur -a ansible_demo"

#Log in to conjur
api_key="$(grep API ansible.out | cut -d: -f2 | tr -d ' \r\n')"
docker-compose exec -T client conjur authn login -u admin -p "$api_key"
