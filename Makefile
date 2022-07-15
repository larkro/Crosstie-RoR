include .env ## Include variables from .env

lint: ## Run hadolint on Dockerfile
	docker run --rm -v `pwd`/.hadolint.yaml:/.config/hadolint.yaml -i hadolint/hadolint < Dockerfile

clone: ## Clone the rails repo to directory rails
	git clone https://github.com/rails/rails.git

docker-build: ## Build the rails docker-image
	docker build -t rails-dev .

docker-convert: ## Display docker compose convert
	docker compose convert

docker-compose-up: ## Start dependency services: memcached, redis, mariadb, postgresql. Variables from .env
	docker-compose up -d

docker-clean-up: ## Stop dependency services: memcached, redis, mariadb, postgresql. Prune containers and volumes
	docker-compose down 
	docker container prune
	docker volume prune

setup-mysql-user: ## Run the rails-dev docker-image to setup the mysql db (mariadb)
	cat mysql-setup-database.sql | docker run -i --network rails-dev \
		rails-dev /usr/bin/mariadb -h mariadb

setup-db: ## Run the rails-dev docker-image to create and build databases
	docker run -i --network rails-dev --env-file .env \
		--env MEMCACHE_SERVERS="memcached:11211" \
		--env MYSQL_HOST=mariadb \
		--env MYSQL_SOCK="/run/mysqld/mysqld.sock" \
		--env REDIS_URL="redis://redis:6379/" \
		--volumes-from=postgres \
		--volumes-from=mariadb \
		-v `pwd`/rails:/usr/src/rails \
		rails-dev /bin/bash -c " \
		cd activerecord ; \
		bundle exec rake db:create ; \
		bundle exec rake db:mysql:build ; \
		bundle exec rake db:postgresql:build"

drop-create-test-db: ## Drop and create test dbs
	docker run -it --network rails-dev --env-file .env \
		--env MEMCACHE_SERVERS="memcached:11211" \
		--env MYSQL_HOST=mariadb \
		--env MYSQL_SOCK="/run/mysqld/mysqld.sock" \
		--env REDIS_URL="redis://redis:6379/" \
		--volumes-from=postgres \
		--volumes-from=mariadb \
		-v `pwd`/rails:/usr/src/rails \
		rails-dev /bin/bash -c " \
		cd activerecord ; \
		bundle exec rake db:drop ; \
		bundle exec rake db:create"

run-command: ## Run command with rails-dev image, default: /bin/bash
	docker run -it --network rails-dev --env-file .env \
		--volumes-from=postgres \
		--volumes-from=mariadb \
		-v `pwd`/rails:/usr/src/rails rails-dev $(RUN_COMMAND)

run-command-without-env: ## Run command with rails-dev image, without env vars, default: /bin/bash
	docker run -it --network rails-dev \
		--volumes-from=postgres \
		--volumes-from=mariadb \
		-v `pwd`/rails:/usr/src/rails rails-dev $(RUN_COMMAND)

run-test: ## Run rails tests in the rails-dev docker-image towards services in docker-compose
	docker run -i --network rails-dev \
		--env MEMCACHE_SERVERS="memcached:11211" \
		--env MYSQL_HOST=mariadb \
		--env MYSQL_SOCK="/run/mysqld/mysqld.sock" \
		--env REDIS_URL="redis://redis:6379/" \
		--env TESTOPTS="" \
		--volumes-from=postgres \
		--volumes-from=mariadb \
		-v `pwd`/rails:/usr/src/rails \
		rails-dev bundle exec rake test

run-test-testops: ## Run rails tests in the rails-dev docker-image ... with testopts, default: --verbose
	docker run -i --network rails-dev \
		--env MEMCACHE_SERVERS="memcached:11211" \
		--env MYSQL_HOST=mariadb \
		--env MYSQL_SOCK="/run/mysqld/mysqld.sock" \
		--env REDIS_URL="redis://redis:6379/" \
		--env TESTOPTS="--verbose" \
		--volumes-from=postgres \
		--volumes-from=mariadb \
		-v `pwd`/rails:/usr/src/rails \
		rails-dev bundle exec rake test

help: ## Display this output.
	@egrep '^[a-zA-Z_-]+:.*?## .*$$' Makefile | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-20s\033[0m %s\n", $$1, $$2}'

.PHONY: clean help lint clone docker-build docker-convert docker-compose-up docker-clean-up setup-mysql-user setup-db drop-create-test-db run-command run-command-without-env run-test run-test-verbose
.DEFAULT_GOAL := help
