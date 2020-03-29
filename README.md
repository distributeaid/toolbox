Toolbox
================================================================================

The collection of tools for newcomer (refugee) aid groups that make up the Distribute Aid platform.

[![pipeline status](https://gitlab.com/distribute-aid/toolbox/badges/master/pipeline.svg)](https://gitlab.com/distribute-aid/toolbox/commits/master) [![coverage report](https://gitlab.com/distribute-aid/toolbox/badges/master/coverage.svg)](https://gitlab.com/distribute-aid/toolbox/commits/master)

Contributing
------------------------------------------------------------

1. Run through the installation steps (see _Up & Running_ below).
2. Make a new branch off `master` and write some code.  Test it.  ;)
3. Push the new branch and make a pull request through gitlab.
4. We'll review your changes.  Commit further changes to the same branch and push them as needed.
5. Once it's ready, we'll approve your pull request and merge your branch into `master`.  They will be deployed along with other updates during our regular releases.

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
* Docs: https://hexdocs.pm/elixir/1.7.4/Kernel.html - NOTE: we are not using the latest version of Elixir just yet.

Phoenix (webserver framework):

* Official website: http://www.phoenixframework.org/
* Docs: https://hexdocs.pm/phoenix/overview.html
* Mailing list: http://groups.google.com/group/phoenix-talk
* Source: https://github.com/phoenixframework/phoenix

Ecto (database framework & ORM):

* Docs: https://hexdocs.pm/ecto/Ecto.html

Up & Running
------------------------------------------------------------

**Setup Docker**

1. Install Docker - https://docs.docker.com/install/
2. Install Docker Compose - https://docs.docker.com/compose/install/
3. Start the Docker daemon.
    - MacOS / Windows: Start the Docker application.
    - Linux: follow [these post-install steps](https://docs.docker.com/install/linux/linux-postinstall/).  Especially "managing docker as non-root" and "configure docker to start on boot".

See the _Common Docker Commands_ section below for more info about how we use Docker.

**Clone The Project**
```
git clone git@gitlab.com:distribute-aid/toolbox.git
cd toolbox/

# Create a 'db' directory.
mkdir db && chmod -R +x db
```

**Run Containers**

* Start: `./build-server.sh` (for Windows, use `./build-server.bat`)
* Stop: `ctrl-c` in the same window, or `docker-compose down` in another

When starting the containers, once you see this message it is ready:

> [info] Running FerryWeb.Endpoint with Cowboy using http://0.0.0.0:1312

If you see that a container has exited (ex: "toolbox_web_1 exited with code 1") then you can bring it up again from another terminal: `docker start $CONTAINER_NAME`.  You can also run `docker ps -a` to see if any containers have exited.

See the _Common Docker Commands_ section below for a list of container names.

**Setup PG Admin**

1. With the containers running, go to http://localhost:8088 in your browser.
2. Log in with username `admin` and password `admin` (unless you overrode the defaults).
3. Create new servers for our dev and test dbs.  See `./build-server.sh` for the connection information (including the hostnames).

**Setup Up Our Site**

If everything is running correctly, you should be able to visit http://localhost:1312 or http://0.0.0.0:1312 and see our site.  The localhost address is used in the rest of this readme, but the 0.0.0.0 address should be the same thing.

We now need to seed a test group and some database constants:

```
docker exec toolbox_db /bin/bash seed-test-group.sh

```

Make sure you only run the following two lines once. 
```
docker exec toolbox_web mix ecto.setup
docker exec --env MIX_ENV=test toolbox_web mix ecto.setup
```

You can now visit http://localhost:1312/public/groups/1/users/new to create a user associated with that group.  Finally, visit http://localhost:1312/public/session/new to log in.

Unfortunately there's no easy way of creating more groups at the moment.  You can use PG Admin to manually add groups, or the command line to insert them.  See the _Managing Dev Databases_ section below for how to connect via the commandline, then use the following INSERT statement:

```
INSERT INTO groups (name, description, inserted_at, updated_at) VALUES ('group name', 'about this group', NOW(), NOW());
```

To create more users, visit http://localhost:1312/public/groups/$GROUP_ID/users/new (replace $GROUP_ID with the id of the group you want to add the user to).  You can add multiple users to a single group.

For adding more data (like groups, shipments, items), register as an aid group. [Here is a screencast](https://www.loom.com/share/78a7cc512bbe4885ac3d8671372437a1) explaining this process in detail.

**API**

A GraphQL API is provided at `/api`. The [Absinthe docs](https://hexdocs.pm/absinthe/overview.html) are a good starting place to learn more about GraphQL in the context of elixir.

You can use a browser implementation of graphiql to view the schema documentation and run test queries: http://localhost:1312/api/graphiql

**Trouble Shooting**

* Try not to have PostgreSQL running locally (potential conflict issues).
* Fix incorrect development folder permissions with: `chmod -R +x development/`.

To verify that the seeds ran correctly select all entries in the groups table (there should be 1).  You can do this from PG Admin or the command line.  See the _Managing Dev Databases_ below for how to connect via the command line, then use the following SELECT statement:

```
SELECT * FROM groups;
SELECT * FROM inventory_mods;
```

Common Docker Commands
------------------------------------------------------------

Docker's commandline documentation: https://docs.docker.com/engine/reference/commandline/

* `docker ps -a` - List containers.  Very useful for getting a container's name, id, or status.  For more information see [Docker's ps documentation](https://docs.docker.com/engine/reference/commandline/ps/).
* `docker exec $CONTAINER_NAME $COMMAND` - Execute a command on a container.  For more information see here [Docker's exec documentation](https://docs.docker.com/engine/reference/commandline/exec/).
* `docker exec -it $CONTAINER_NAME /bin/bash` - Enter a bash shell on a container where you can run multiple mix commands in a row.  This is very useful for the web container.

Our docker container names are:

* **toolbox_web** - The elixir dev server.  All mix commands will be run on this container.
* **toolbox_db** - Our dev database.  This is the database that you interact with from the locally hosted development site.
* **dbtest** - Our test database.  `mix test` and `MIX_ENV=test $command` will both use this database.
* **dbadmin** - The PG Admin server.

Common Mix Commands
------------------------------------------------------------

**Pheonix:**

* https://hexdocs.pm/phoenix/phoenix_mix_tasks.html#content
* You can also lookup each individual task in the mix section of the left side menu.
* See `/development/web-entrypoint.sh` for common commands that are run when you start the containers.

```
# list all routes in the app
docker exec toolbox_web mix phx.routes

# code generation (look these up in the docs- many options)
# NOTE: Don't run code generation tasks through the Docker container.
#       They generated files will have the wrong permissions.
mix phx.gen.schema [OPTIONS]
mix phx.gen.context [OPTIONS]
mix phx.gen.html [OPTIONS]
```

**Ecto:**

* https://hexdocs.pm/ecto/Mix.Tasks.Ecto.html (select a specific task in the left side menu)

```
docker exec toolbox_web mix ecto.migrate
docker exec toolbox_web mix ecto.rollback -n 1
docker exec toolbox_web mix ecto.reset

mix ecto.gen.migration "migration name"
```

**Testing:**

* https://hexdocs.pm/mix/Mix.Tasks.Test.html
* https://github.com/parroty/excoveralls#mix-coveralls-show-coverage

```
docker exec toolbox_web mix test --color

# run specific tests- all in a folder, all in a file, or even just a single one
docker exec toolbox_web mix test --color test/$PATH_TO_FOLDER_OR_FILE
docker exec toolbox_web mix test --color test/$PATH:$TEST_LINE_NUMBER

# run tests synchronously, in order
docker exec toolbox_web mix test --color --trace

# for code coverage
docker exec toolbox_web mix coveralls
docker exec --env MIX_ENV=test toolbox_web mix coveralls.html
```

Mix commands can be targeted to the test environment / database by setting an environment variable `MIX_ENV=test`.  There are three ways to do this:

1. Specify an environment variable using docker exec's `--env` flag.  EX: `docker exec --env MIX_ENV=test toolbox_web mix ecto.reset`
2. Run a shell command which executes another command that starts by setting the environment variable.  EX: `docker exec toolbox_web sh -c "MIX_ENV=test mex ecto.reset`.
3. Finally, you can always open a bash shell on the web container and run the commands directly.  EX: `docker exec -it toolbox_web /bin/bash` and then `MIX_ENV=test mix ecto.reset` in the shell.

**Code Quality**
```
# credo performs static code analysis
docker exec toolbox_web mix credo list

# to learn more about a particular issue in credo
docker exec toolbox_web mix credo explain file/and/linenumber.ex:101

# format a file in the standard elixir style
docker exec toolbox_web mix format "path/to/file.ex"
docker exec toolbox_web mix format "pattern/**/path/*.{ex,exs}"
```

Managing Dev Databases
------------------------------------------------------------

**PG Admin:** With the docker containers running, go to http://localhost:8088 in your browser.  Log in with username `admin` and password `admin`.  You should now be able to use the PG Admin GUI to manage your local dev databases.

**psql:** If you prefer to use the commandline, you can run psql in the database docker containers:

```
# dev database
docker exec -it toolbox_db sh -c "psql -U toolbox -d toolbox_dev"

# test database
docker exec -it dbtest sh -c "psql -U toolbox -d toolbox_dev"
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
cd assets && npm install && npm run deploy && cd ..
MIX_ENV=prod mix phx.digest
MIX_ENV=prod mix Distillery.release --env=prod --upgrade

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
