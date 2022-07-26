# Crosstie RoR

Contain your development.
Crossties, small boxes that keeps the Rails in place.
A metaphore of using containers as a supportive tool to develop Rails.

_A railroad tie, crosstie, railway tie or railway sleeper is a rectangular support for the rails in railroad tracks. Generally laid perpendicular to the rails, ties transfer loads to the track ballast and subgrade, hold the rails upright and keep them spaced to the correct gauge. -- [Wikipedia](https://en.wikipedia.org/wiki/Railroad_tie)_

* This PoC is a fun summer pet project, WORK IN PROGRESS and built on Mac.

## Background

Insprired by [RailsConf 2022 - Keynote: The Success of Ruby on Rails by Eileen Uchitelle](https://www.youtube.com/watch?v=MbqJzACF-54).
In the talk there is a part about `contributing to Rails`
and looking at the [development_dependencies_install](https://guides.rubyonrails.org/development_dependencies_install.html)
there are two ways, `The easy way.`
"We supply the container that runs Codespaces and you can use that with VSCode"
`And the hard way.`
"[It took me more than 12 hours to get Ruby 3.1 and MySQL to play nice!](https://youtu.be/MbqJzACF-54?t=1785)".

Could I contribute? Maybe I can make it easier, less scary, for others to contribute?
Inspired by the talk: _You don't need to invent something major_

### Goals

* work with the code locally with your favorite IDE, run everything in containes.
* minimal install on your local machine (brew, git, make).
* easily switch versions of ruby, postgres, mariadb/mysql, memcached and redis.

## Prerequisite

You need `brew`, `git` and `make`.

### Getting started, TL;DR

If you have the prerequiste you can:

```bash
make install            # Use brew to install: colima kubectl docker docker-compose
make colima             # Start colima with kubernetes and $HOME writable
make clone              # Clone the rails repo to directory rails
make docker-build       # Build the rails docker-image
make docker-compose-up  # Start dependency services: memcached, redis, mariadb, postgresql. Variables from .env
```

## Getting started, how to work with this

After TL;DR `make docker-compose-up` you got an environment with all needed services running in containers and a docker image `rails-dev` where your code can be tested.

As is, some database things need to be setup run `make setup-mysql-user` and `make setup-db`.
Give mariadb a few sec to boot between docker-compose-up and setup-mysql-user.
These two commands are partly redundant, and will be updated once I have had the time to look into the existing tasks and documentation about setting up the databases.

Edit .env for specific versions.

Use you favorite IDE to edit files in directory `rails`.

Start an instance of `rails-dev` using `make run-command` (will mount directory `rails`) where you can manually run the tests for the thing you are working on. Adding `gems` or other dependencies requires rebuilding the `make docker-build` step so it's available in the running container.

Example:

```bash
$ make run-command
docker run -it --network rails-net --env-file .env \
                --volumes-from=postgres \
                --volumes-from=mariadb \
                -v `pwd`/rails:/usr/src/rails rails-dev:3.1 "/bin/bash"
root@hostname:/usr/src/rails# cd activerecord
root@hostname:/usr/src/rails# bin/test test/cases/binary_test.rb -n test_load_save
Using sqlite3
Run options: -n test_load_save --seed 19719

# Running:

.

Finished in 0.104350s, 9.5831 runs/s, 86.2482 assertions/s.
1 runs, 9 assertions, 0 failures, 0 errors, 0 skips
```

## Recommended Workflow

The recommended workflow is

* pick the versions of each dependency in .env

* edit rails files in the host computer with your favorite IDE and

* run a container with a shell where you run tests.

### What it is build on

A container engine that can run docker images, we have used `colima`.
[Instructions to use Colima](https://smallsharpsoftwaretools.com/tutorials/use-colima-to-run-docker-containers-on-macos/)

**note:** colima must be started with write permissions, add:

```bash
--mount ${HOME}:w`
````

Default mount is read only, write is needed when running rails tests.

The tools we have used can easliy be installed using `HomeBrew`.

```bash
brew install colima
brew install kubectl
brew install docker
brew install docker-compose
```

Read more about it:
[colima](https://github.com/abiosoft/colima) - Container runtimes on macOS (and Linux) with minimal setup

For extra fun start it with `kubernetes` support, add some cpu and ram.
Yes, future plans includes running `Crossties` in kubernetes,
running multple versions at the same time,
hosted in different places,
gather metrics/logs/stuff using that ecosystem.

```bash
colima start --with-kubernetes --cpu 6 --memory 6 --mount ${HOME}:w
```

## How to

Things are "documented" in `Makefile`.
Run `make` to see the help.

The short story.

```make
install              Use brew to install: colima kubectl docker docker-compose
colima               Start colima with kubernetes and $HOME writable
lint                 Run hadolint on Dockerfile
clone                Clone the rails repo to directory rails
docker-build         Build the rails docker-image
docker-convert       Display docker compose convert
docker-compose-up    Start dependency services: memcached, redis, mariadb, postgresql. Variables from .env
docker-clean-up      Stop dependency services: memcached, redis, mariadb, postgresql. Prune containers and volumes
setup-mysql-user     Run the rails-dev docker-image to setup the mysql db (mariadb)
setup-db             Run the rails-dev docker-image to create and build databases
drop-create-test-db  Drop and create test dbs
run-command          Run command with rails-dev image, default: /bin/bash
run-command-without-env Run command with rails-dev image, without env vars, default: /bin/bash
run-test             Run rails tests in the rails-dev docker-image towards services in docker-compose
run-test-testops     Run rails tests in the rails-dev docker-image ... with testopts, default: --verbose
help                 Display this output.
```

## Example

Edit files locally in your prefered IDE.

```bash
sed -i".bak" 's/Spammer layout We do not spam/This should show up as fail/' rails/actionmailer/test/mail_layout_test.rb
```

Run test, often easier to start a container with a shell and manually run it in another terminal.

```bash
make RUN_COMMAND="/bin/bash -c 'cd actionmailer && bin/test test/mail_layout_test.rb -n test_explicit_class_layout'" run-command
```

See the error and iterate until pass.

```bash
# Running:

F

Failure:
LayoutMailerTest#test_explicit_class_layout [/usr/src/rails/actionmailer/test/mail_layout_test.rb:90]:
--- expected
+++ actual
@@ -1 +1 @@
-"This should show up as fail"
+"Spammer layout We do not spam"
```

## Issues

Still a lot. :-) Just started.
Create Issues in git for better tracking.
Some general things are:

Too much is running with too high privilege and access is without proper authentication.
First step is to make it work.
Then make it work in a more correct way.

Look into why some tests are skipped and good ways of handling version deps and such.
