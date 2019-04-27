Toolbox
================================================================================

The collection of tools for newcomer (refugee) aid groups that make up the Distribute Aid platform.

[![pipeline status](https://gitlab.com/distribute-aid/toolbox/badges/master/pipeline.svg)](https://gitlab.com/distribute-aid/toolbox/commits/master) [![coverage report](https://gitlab.com/distribute-aid/toolbox/badges/master/coverage.svg)](https://gitlab.com/distribute-aid/toolbox/commits/master)

Up & Running
------------------------------------------------------------

```
# Install Docker - https://docs.docker.com/install/
# Install Docker Compose - https://docs.docker.com/compose/install/

# Start the Docker daemon. This can vary depending on your OS - MacOS/Windows users should just need to start the Docker application however on Linux you may need to follow some of [these](https://docs.docker.com/install/linux/linux-postinstall/) post-installation steps.

# Clone The Project
git clone git@gitlab.com:distribute-aid/toolbox.git

# Change Directory into toolbox
cd toolbox/

**DO WE NEED THIS ANYMORE?**
# Create a 'db' directory
mkdir db && chmod -R +x db

# Run this to build and bring up the containers using docker-compose
./build-server.sh

# Once the message `[info] Running FerryWeb.Endpoint with Cowboy using http://0.0.0.0:1312` appears in the log it is ready to run
# If you see "toolbox_web_1 exited with code 1", create another terminal, and inside of the toolbox dir run
docker ps -a
# run
docker start $NAME_OF_TOOLBOX_HERE

# To stop the containers, run:
docker-compose down

# Execute commands on a particular container (https://docs.docker.com/engine/reference/commandline/ps/):
docker ps -a
docker exec $image_id command

# Commands can also be run on running containers
docker exec $(docker ps -aqf "name=toolbox_web*") mix ecto.create
docker exec $(docker ps -aqf "name=toolbox_web*") mix ecto.migrate
docker exec $(docker ps -aqf "name=toolbox_web*") mix ecto.reset
docker exec $(docker ps -aqf "name=toolbox_web*") mix test

# For more information, see here: https://docs.docker.com/engine/reference/commandline/exec/

# To execute an interactive bash shell
docker exec -it $image_id /bin/bash

# Setup the seed test group
docker exec $(docker ps -aqf "name=toolbox_db*") /bin/bash seed-test-group.sh
```

Troubleshooting
------------------------------------------------------------
  - Incorrect development folder permissions, run: `chmod -R +x development/`
  - Try not to have PostgreSQL running locally (potential conflict issues)


Development
------------------------------------------------------------
With the docker containers running, - open [http://0.0.0.0:1312] in your browser
To create new users: http://localhost:1312/public/groups/GROUP_ID/users/new
Replace GROUP_ID in the above url with the group id from the table that was generated after you added group1 to the database using the `seed-test-group.sh` script

Database Reset: `docker exec $(docker ps -aqf "name=toolbox_web*") mix ecto.reset`

Database Administration
------------------------------------------------------------
1. Go to http://0.0.0.0:8088 in your browser
2. Login using the credentials specified in `PGADMIN_DEFAULT_EMAIL` and `PGADMIN_DEFAULT_PASSWORD` ('admin' and 'admin' unless you overwrote the defaults).
3. Create a New Server - under 'General' give it a name and optionally specify comments/connection colours. On the Connection tab enter 'db' as the Host name and the values for `POSTGRES_USER` and `POSTGRES_PASSWORD` as the Username and Password respectively ('toolbox' and '1312' are the default values).

Testing
------------------------------------------------------------
Run Tests:

  - `docker exec $(docker ps -aqf "name=toolbox_web*") mix test`
  - `docker exec $(docker ps -aqf "name=toolbox_web*") mix test --trace` for detailed output
  - `docker exec $(docker ps -aqf "name=toolbox_web*") mix coverall` for code coverage

Mix commands can be targeted to the test environment by prepending `MIX_ENV=test`.  For example, to reset the test database after changing a schema that you are working on, run `MIX_ENV=test mix ecto.reset`.

Gitlab runs tests & code coverage in a continuous integration pipeline when code is pushed to `origin`.

Contributing
------------------------------------------------------------
 1. Run through the installation steps (see *Up & Running* above).
 2. Make a new branch off `master` and write some code.  Test it.  ;)
 3. Push the new branch and make a pull request through gitlab.
 4. A team member will review your changes.  Commit further changes to the same branch and push them as needed.
 5. The team member will approve your pull request and merge your branch into `master` once it is ready.  They will be deployed along with other updates during our regular releases.

Deployment
------------------------------------------------------------

**Deployment Setup**

```
# log into the server
ssh [user]@distributeaid.org
cd ~/toolbox/

# build
git pull
mix deps.get --only prod
MIX_ENV=prod mix compile
MIX_ENV=prod mix ecto.migrate
cd assets && npm install && ./node_modules/brunch/bin/brunch b -p && cd .. && MIX_ENV=prod mix do phx.digest, release --env=prod --upgrade

# deploy
cd [/path/to/webroot]
mkdir releases/[version]
cp ~/toolbox/_build/prod/rel/ferry/releases/[version]/ferry.tar.gz releases/[version]
./bin/ferry upgrade [version]
PORT=1337 ./bin/ferry restart # needed to ensure updated static assets are used
```

Metrics
------------------------------------------------------------
TODO

Backups
------------------------------------------------------------

### Secrets

**Backup:**

```
scp [user]@distributeaid.org:/home/[user]/toolbox/config/prod.secret.exs [/path/to/backups]/toolbox/
```

**Restore:**
```
TODO
```

### Nginx Config

**Backup:**

```
scp [user]@distributeaid.org:/etc/nginx/nginx.conf [/path/to/backups]/nginx

scp -r [user]@distributeaid.org:/etc/nginx/sites-available [/path/to/backups]/nginx
```

**Restore:**

```
TODO
```

Links
------------------------------------------------------------
Elixir (programming language):

  * Official website: [https://elixir-lang.org/]
  * Getting started guide: [https://elixir-lang.org/getting-started/introduction.html]
  * Docs: [https://hexdocs.pm/elixir/Kernel.html]

Phoenix (webserver framework):

  * Official website: [http://www.phoenixframework.org/]
  * Docs: [https://hexdocs.pm/phoenix]
  * Mailing list: [http://groups.google.com/group/phoenix-talk]
  * Source: [https://github.com/phoenixframework/phoenix]

Ecto (database framework & ORM):

  * Docs: [https://hexdocs.pm/ecto/Ecto.html]

Ex Unit (testing framework):

  * Docs: [https://hexdocs.pm/ex_unit/ExUnit.html]

Copyright & Licensing
------------------------------------------------------------
Our source code is released under the AGPLv3 license.  You can find the full license in `LICENSE.md`.  The license notice has been included below:

```
Toolbox: Web tools for refugee aid groups.
Copyright (C) 2018-2019  Distribute Aid
https://distributeaid.org
code@distributeaid.org

Toolbox is free software: you can redistribute it and/or modify
it under the terms of the GNU Affero General Public License as
published by the Free Software Foundation, either version 3 of
the License, or (at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU Affero General Public License for more details.

You should have received a copy of the GNU Affero General Public License
along with this program.  If not, see <https://www.gnu.org/licenses/>.
```

TODO: Ensure the short version of license notice appears in each source code file.

TODO: Ensure that appropriate code license & content license notices appear on each page of the site.

TODO: Document licenses of all libraries used.
