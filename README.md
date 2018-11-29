Toolbox
================================================================================

The collection of tools for newcomer (refugee) aid groups that make up the Distribute Aid platform.

[![pipeline status](https://gitlab.com/distribute-aid/toolbox/badges/master/pipeline.svg)](https://gitlab.com/distribute-aid/toolbox/commits/master) [![coverage report](https://gitlab.com/distribute-aid/toolbox/badges/master/coverage.svg)](https://gitlab.com/distribute-aid/toolbox/commits/master)

Up & Running
------------------------------------------------------------
```
# Install Packages - Mac OSX
# Uses Homebrew: [https://brew.sh/]
brew install elixir
brew install postgres
brew install node

# OR Install Packages - Ubuntu
wget https://packages.erlang-solutions.com/erlang-solutions_1.0_all.deb && sudo dpkg -i erlang-solutions_1.0_all.deb
sudo apt-get update
sudo apt-get install esl-erlang
sudo apt-get install elixir
sudo apt-get install postgresql postgresql-contrib
sudo apt-get install nodejs
sudo apt-get install npm
sudo ln -s /usr/bin/nodejs /usr/bin/node

# Clone The Project
git clone git@gitlab.com:distribute-aid/toolbox.git
cd toolbox/

# Install Hex Packages
mix local.hex
mix deps.get
mix deps.compile
cd assets && npm install && node node_modules/brunch/bin/brunch build

# Setup Postgres
psql -d postgres
CREATE USER toolbox WITH PASSWORD '1312';
CREATE DATABASE toolbox_dev;
GRANT ALL PRIVILEGES ON DATABASE toolbox_dev to toolbox;
ALTER USER toolbox CREATEDB;
\q
mix ecto.create
mix ecto.migrate

# Run Our Dev Tools
mix phx.server
mix test
```

Development
------------------------------------------------------------
Dev Server: `mix phx.server` - open [http://localhost:1312] in your browser

Database Reset: `mix ecto.reset`

Testing
------------------------------------------------------------
Run Tests:

  - `mix test`
  - `mix test --trace` for detailed output
  - `mix coverall` for code coverage

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
TODO: Document the deployment process during the first (successful) deploy.

Metrics
------------------------------------------------------------
TODO

Backups
------------------------------------------------------------
TODO

Links
------------------------------------------------------------
Elixir (programming language):

  * Official website: [https://elixir-lang.org/]
  * Getting started guide: [https://elixir-lang.org/getting-started/introduction.html]
  * Docs: [https://hexdocs.pm/elixir/Kernel.html]

Phoenix (webserver framework):

  * Official website: [http://www.phoenixframework.org/]
  * Guides: [http://phoenixframework.org/docs/overview]
  * Docs: [https://hexdocs.pm/phoenix]
  * Mailing list: [http://groups.google.com/group/phoenix-talk]
  * Source: [https://github.com/phoenixframework/phoenix]

Ecto (database framework & ORM):

  * Docs: [https://hexdocs.pm/ecto/Ecto.html]

Ex Unit (testing framework):

  * Docs: [https://hexdocs.pm/ex_unit/ExUnit.html]

Copyright & Licensing
------------------------------------------------------------
TODO: Ensure license notice appears in each source code file.

TODO: Ensure that appropriate code license & content license notices appear on each page of the site.

TODO: Document licenses of all libraries used.