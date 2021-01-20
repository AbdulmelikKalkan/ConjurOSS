# ConjurOSS
This repository provides to have environment of <a href='https://github.com/cyberark/conjur-quickstart'>Conjur OpenSource</a> using vagrant and docker compose.

#### Run the demo app

1. Start a bash session

   Enter the BotApp container.
   ```
   docker exec -i -t bot_app bash
   ```

1. Generate a Conjur token

   Generate a Conjur token to the conjur_token file, using the BotApp API key:
   ```
   curl -d "<BotApp API Key>" -k https://proxy/authn/myConjurAccount/host%2FBotApp%2FmyDemoApp/authenticate > /tmp/conjur_token
   ```

   The Conjur token is stored in the conjur_token file.

1. Fetch the secret

   Run program to fetch the secret:
   ```
   /tmp/program.sh
   ```

   The secret is displayed.

   TIP: If the secret is not displayed, try generating the token again.  You have eight minutes between generating the conjur token and fetching the secret with BotApp.
