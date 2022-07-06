# Crosstie RoR

Contain your development.
Crossties, small boxes that keeps the Rails in place.
A metaphore of using containers as a supportive tool to develop Rails.

_A railroad tie, crosstie, railway tie or railway sleeper is a rectangular support for the rails in railroad tracks. Generally laid perpendicular to the rails, ties transfer loads to the track ballast and subgrade, hold the rails upright and keep them spaced to the correct gauge. -- [Wikipedia](https://en.wikipedia.org/wiki/Railroad_tie)_

* This PoC is WORK IN PROGRESS and built on Mac.

## Background

Insprired by `RailsConf 2022 - Keynote: The Success of Ruby on Rails by Eileen Uchitelle`.
In the talk there is a part about `contributing to Rails`
and looking at the [development_dependencies_install](https://guides.rubyonrails.org/development_dependencies_install.html)
there are two ways, `The easy way.`
"We supply the container that runs Codespaces and you can use that with VSCode"
`And the hard way.`
"It took me more than 12 hours to get Ruby 3.1 and MySQL to play nice!".

Goal: run container locally with the stuff needed for you and your favorite IDE to contribute to rails.

## Prerequisite

Some container engine that can run docker images, we have used `colima`.
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

```bash
colima start --with-kubernetes --cpu 6 --memory 6 --mount ${HOME}:w
```

## How to

Things are "documented" in `Makefile`.
Run `make` to see the help.

The short story.

```bash
$ make clone        # Will clone rails git repo to directory rails
$ make docker-build # Build the rails docker-image
$ docker-compose-up # Start dependency services, memcached, redis, mariadb, postgresql
$ setup-mysql-user  # Run the rails-dev docker-container to setup the mysql db (mariadb)
$ setup-db          # Run the rails-dev docker-container to create and build databases
# Edit files / tests in directory rails, it will be mounted by the image.
$ run-test          # Run rails tests in the rails-dev docker-container towards services in docker-compose
```

## Issues

Create Issues in git for better tracking.
Some general things are:

Too much is running with too high privilege and access is without proper authentication.
First step is to make it work.
Then make it work in a more correct way.

Look into why some tests are skipped.
