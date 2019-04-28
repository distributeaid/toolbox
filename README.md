Toolbox
================================================================================

The collection of tools for newcomer (refugee) aid groups that make up the Distribute Aid platform.

[![pipeline status](https://gitlab.com/distribute-aid/toolbox/badges/master/pipeline.svg)](https://gitlab.com/distribute-aid/toolbox/commits/master) [![coverage report](https://gitlab.com/distribute-aid/toolbox/badges/master/coverage.svg)](https://gitlab.com/distribute-aid/toolbox/commits/master)

Contributing
------------------------------------------------------------

1. Run through the installation steps (see _Up & Running_ below).
2. Make a new branch off `master` and write some code.  Test it.  ;)
3. Push the new branch and make a pull request through gitlab.
4. A team member will review your changes.  Commit further changes to the same branch and push them as needed.
5. The team member will approve your pull request and merge your branch into `master` once it is ready.  They will be deployed along with other updates during our regular releases.

Links
------------------------------------------------------------

Distribute Aid:

* Landing site: https://distributeaid.org/
* Tools: https://toolbox.distributeaid.org/
* Facebook: https://facebook.com/DistributeAidDotOrg
* Patreon: https://patreon.com/distributeaid

Elixir (programming language):

* Official website: https://elixir-lang.org/
* Getting started guide: https://elixir-lang.org/getting-started/introduction.html
* Docs: https://hexdocs.pm/elixir/1.7.2/Kernel.html - NOTE: we are not using the latest version of Elixir just yet.

Phoenix (webserver framework):

* Official website: http://www.phoenixframework.org/
* Docs: https://hexdocs.pm/phoenix/1.3.4/overview.html - NOTE: we are not using the latest version of Phoenix just yet.
* Mailing list: http://groups.google.com/group/phoenix-talk
* Source: https://github.com/phoenixframework/phoenix

Ecto (database framework & ORM):

* Docs: https://hexdocs.pm/ecto/2.2.11/Ecto.html - NOTE: we are not using the latest version of Ecto just yet.

Up & Running
------------------------------------------------------------

**Setup Docker**

1. Install Docker - https://docs.docker.com/install/
2. Install Docker Compose - https://docs.docker.com/compose/install/
3. Start the Docker daemon.
    - MacOS / Windows: Start the Docker application.
    - Linux: follow [these post-install steps](https://docs.docker.com/install/linux/linux-postinstall/).  Especially "managing docker as non-root" and "configure docker to start on boot".

**Clone The Project**
```
git clone git@gitlab.com:distribute-aid/toolbox.git
cd toolbox/

# Create a 'db' directory.
mkdir db && chmod -R +x db
```

**Run Containers**

* Start: `./bulid-server.sh`
* Stop: `ctrl-c` in the same window, or `docker-compose down` in another

When starting the containers, once you see the message "_\[info\] Running FerryWeb.Endpoint with Cowboy using http://0.0.0.0:1312_" then it is ready.

If you see that a container has exited (ex: "toolbox_web_1 exited with code 1") then you can bring it up again from another terminal: `docker start $NAME_OF_CONTAINER`.  You can also run `docker ps -a` to see if any containers have exited.

**Setup PG Admin**

1. With the containers running, go to http://localhost:8088 in your browser.
2. Log in with username `admin` and password `admin` (unless you overrode the defaults).
3. Create new servers for our dev and test dbs.  See `./build-server.sh` for the connection information (including the hostnames).

**Setup Up Our Site**

If everything is running correctly, you should be able to visit http://localhost:1312 or http://0.0.0.0:1312 and see our site.  The localhost address is used in the rest of this readme, but the 0.0.0.0 address should be the same thing.

We now need to seed a test group:

```
# 1) list containers
docker ps -a

# 2) run the seed script
docker exec $db_container_id /bin/bash seed-test-group.sh
```

You can now visit http://localhost:1312/public/groups/1/users/new to create a user associated with that group.  Finally, visit http://localhost:1312/public/session/new to log in.

Unfortunately there's no easy way of creating more groups at the moment.  You can use PG Admin to manually add groups, or the command line to insert them.  See Managing Dev Databases below for how to connect via the commandline, then use the following INSERT statement:

```
INSERT INTO groups (name, description, inserted_at, updated_at) VALUES ('group name', 'about this group', NOW(), NOW());
```

To create more users, visit http://localhost:1312/public/groups/$GROUP_ID/users/new (replace $GROUP_ID with the id of the group you want to add the user to).  You can add multiple users to a single group.

**Trouble Shooting**

* Try not to have PostgreSQL running locally (potential conflict issues).
* Fix incorrect development folder permissions with: `chmod -R +x development/`.

To verify that the seeds ran correctly:

```
# 1) list containers
docker ps -a

# 2) open a bash shell into the db contianer
docker exec -it $db_container_id /bin/bash

# 3) open postgres
psql -U toolbox -d toolbox_dev

# 4) verify that seeded data is there
SELECT * FROM groups;
...
```

Common Docker Commands
------------------------------------------------------------

Docker's commandline documentation: https://docs.docker.com/engine/reference/commandline/

* `docker ps -a` - List containers.  Very useful for getting a container's ID to use in other commands.  For more information see [Docker's ps documentation](https://docs.docker.com/engine/reference/commandline/ps/).
* `docker exec $container_id $command` - Execute a command on a container.  For more information see here [Docker's exec documentation](https://docs.docker.com/engine/reference/commandline/exec/).
* `docker exec -it $container_id /bin/bash` - Enter a bash shell on a container.

Common Mix Commands
------------------------------------------------------------

All of these tasks should be run on the web container.  There are three different ways to run them:

1. You can use `docker ps -a` to get the web container ID and replace `$id` in the commands.
2. You can also replace `$id` with `$(docker ps -aqf "name=toolbox_web*")` to run the command in 1 step. EX: `docker exec $(docker ps -aqf "name=toolbox_web*") mix test --color`
3. Finally, you can always open a bash shell on the web container and run the commands directly.  EX: `docker exec -it $container_id /bin/bash` and then `mix test --color` in the shell.

**Pheonix:**

* https://hexdocs.pm/1.3.4/phoenix/phoenix_mix_tasks.html#content
* You can also lookup each individual task in the mix section of the left side menu.
* See `/development/web-entrypoint.sh` for common commands that are run when you start the containers.

```
# list all routes in the app
docker exec $web_container_id mix phx.routes

# code generation (look these up in the docs- many options)
docker exec $web_container_id mix phx.gen.schema [OPTIONS]
docker exec $web_container_id mix phx.gen.context [OPTIONS]
docker exec $web_container_id mix phx.gen.html [OPTIONS]
```

**Ecto:**

* https://hexdocs.pm/ecto/2.2.11/Mix.Tasks.Ecto.html (select a specific task in the left side menu)

```
docker exec $web_container_id mix ecto.migrate
docker exec $web_container_id mix ecto.rollback -n 1
docker exec $web_container_id mix ecto.reset
```

**Testing:**

* https://hexdocs.pm/mix/Mix.Tasks.Test.html
* https://github.com/parroty/excoveralls#mix-coveralls-show-coverage

```
docker exec $web_container_id mix test --color

# for detailed output
docker exec $web_container_id mix test --color --trace

# for code coverage
docker exec $web_container_id mix coverall
```

Mix commands can be targeted to the test environment / database by setting an environment variable `MIX_ENV=test`.  There are three ways to do this:

1. Specify an environment variable using docker exec's `--env` flag.  EX: `docker exec --env MIX_ENV=test $web_container_id mix ecto.reset`
2. Run a shell command which executes another command that starts by setting the environment variable.  EX: `docker exec $web_container_id sh -c "MIX_ENV=test mex ecto.reset`.
3. Finally, you can always open a bash shell on the web container and run the commands directly.  EX: `docker exec -it $container_id /bin/bash` and then `MIX_ENV=test mix ecto.reset` in the shell.

Managing Dev Databases
------------------------------------------------------------

**PG Admin:** With the docker containers running, go to http://localhost:8088 in your browser.  Log in with username `admin` and password `admin`.  You should now be able to use the PG Admin GUI to manage your local dev databases.

**psql:** If you prefer to use the commandline, you can run psql in the database docker containers:

```
# list containers
docker ps -a

# dev db
docker exec -it $db_container_id /bin/bash
psql -U toolbox -d toolbox_dev

# test db
docker exec -it $db_test_container_id /bin/bash
psql -U toolbox -d toolbox_test
```

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

**Secrets**

Backup:

```
scp [user]@distributeaid.org:/home/[user]/toolbox/config/prod.secret.exs [/path/to/backups]/toolbox/
```

Restore:

```
TODO
```

**Nginx Config**

Backup:

```
scp [user]@distributeaid.org:/etc/nginx/nginx.conf [/path/to/backups]/nginx

scp -r [user]@distributeaid.org:/etc/nginx/sites-available [/path/to/backups]/nginx
```

Restore:

```
TODO
```

Copyright & Licensing
------------------------------------------------------------

Our source code is released under the AGPLv3 license.  You can find the full license in `LICENSE.md`.  The license notice has been included below:

> Toolbox: Web tools for refugee aid groups.
> 
> Copyright (C) 2018-2019  Distribute Aid
> 
> https://distributeaid.org --- code@distributeaid.org
> 
> Toolbox is free software: you can redistribute it and/or modify
> it under the terms of the GNU Affero General Public License as
> published by the Free Software Foundation, either version 3 of
> the License, or (at your option) any later version.
> 
> This program is distributed in the hope that it will be useful,
> but WITHOUT ANY WARRANTY; without even the implied warranty of
> MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
> GNU Affero General Public License for more details.
> 
> You should have received a copy of the GNU Affero General Public License
> along with this program.  If not, see <https://www.gnu.org/licenses/>.

TODO: Ensure the short version of license notice appears in each source code file.

TODO: Ensure that appropriate code license & content license notices appear on each page of the site.

TODO: Document licenses of all libraries used.
