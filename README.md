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

$ `colima start --with-kubernetes --cpu 4 --memory 4`

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

## Notes / Issues

Got some issues with `redis`. Error msg
`/usr/local/bundle/gems/redis-4.5.1/lib/redis/client.rb:473:in '_parse_options': invalid uri scheme '' (ArgumentError)`

~~postgres versions issues, or at least with the pg_dump. pg_dump: error: server version: 14.4 (Debian 14.4-1.pgdg110+1); pg_dump version: 13.7 (Debian 13.7-0+deb11u1)
pg_dump: error: aborting because of server version mismatch~~ Downgraded in docker-compose to image: "postgres:13".

Way too much is running as `root` and access is without proper authentication.
First step is to make it work.
Then make it work in a more correct way.

Look into why some tests are skipped.

Postgres as "foreign_server" fails `ForeignTableTest#test_update_record:
RuntimeError: Wrapped undumpable exception for: ActiveRecord::StatementInvalid: PG::SqlclientUnableToEstablishSqlconnection: ERROR:  could not connect to server "foreign_server"
DETAIL:  connection to server on socket "/var/run/postgresql/.s.PGSQL.5432" failed: FATAL:  role "postgres" does not exist`
At a first glance it looks like multiple roles/access types are needed. Looks like some access is via socket and some via TCP. Can not use DATABASE_URL since it breaks other things and running docker-image as USER postgres breaks something else.

Needed to add more cpu and ram `--cpu 4 --memory 4` on my old Macbbook.

Needed to install yarn and eslint in Dockerfile. `/bin/sh: 1: eslint: not found`

Added MARIADB_ALLOW_EMPTY_ROOT_PASSWORD=true and MARIADB_MYSQL_LOCALHOST_GRANTS=true to `docker-compose`
because of access between different pods. Error was: `Access denied for user 'rails'@'172.18.0.6' (using password: NO) (Mysql2::Error::ConnectionError)`

Installed `poppler-utils` in `Dockerfile`
because of error msg: `ActiveStorage::Previewer::PopplerPDFPreviewerTest#test_previewing_a_PDF_that_can't_be_previewed [/usr/src/rails/activestorage/test/previewer/poppler_pdf_previewer_test.rb:38]:
[ActiveStorage::PreviewError] exception expected, not
Class: <Errno::ENOENT>
Message: <"No such file or directory - pdftoppm">`

And the same with `libvips42` because of error msg: `ActiveStorage::Representations::RedirectControllerWithVariantsTest#test_showing_variant_inline:
LoadError: Could not open library 'vips.so.42': vips.so.42: cannot open shared object file: No such file or directory.
Could not open library 'libvips.so.42': libvips.so.42: cannot open shared object file: No such file or directory`

Instructions [development_dependencies_install](https://guides.rubyonrails.org/development_dependencies_install.html) for 2.3.2 Ubuntu talk about mysql, but it's no longer the standard app so instead `Dockerfile` is updated with packages
`mariadb-server
libmariadb-dev-compat
libmariadb-dev`
