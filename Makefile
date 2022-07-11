lint: ## Run hadolint on Dockerfile
	docker run --rm -v `pwd`/.hadolint.yaml:/.config/hadolint.yaml -i hadolint/hadolint < Dockerfile

clone: ## Clone the rails repo to directory rails
	git clone https://github.com/rails/rails.git

pull: ## Git pull the rails repo to directory rails
	cd rails
	git pull

docker-build: ## Build the rails docker-image
	docker build -t rails-dev .

docker-compose-up: ## Start dependency services: memcached, redis, mariadb, postgresql
	docker-compose up -d

get-shell: ## Run the rails-dev docker-image to get a shell
	docker run -it --network rails-dev \
		--env REDIS_URL="redis://redis:6379/" \
		--env MEMCACHE_SERVERS="memcached:11211" \
		--env MYSQL_HOST=mariadb \
		--env MYSQL_SOCK="/run/mysqld/mysqld.sock" \
		--volumes-from=postgres \
		--volumes-from=mariadb \
		-v `pwd`/rails:/usr/src/rails rails-dev /bin/bash

setup-mysql-user: ## Run the rails-dev docker-image to setup the mysql db (mariadb)
	cat mysql-setup-database.sql | docker run -i --network rails-dev \
		--env MYSQL_HOST=mariadb \
		rails-dev /usr/bin/mariadb -h mariadb 

setup-db: ## Run the rails-dev docker-image to create and build databases
	docker run -i --network rails-dev \
		--env REDIS_URL="redis://redis:6379/" \
		--env MEMCACHE_SERVERS="memcached:11211" \
		--env MYSQL_HOST=mariadb \
		--env MYSQL_SOCK="/run/mysqld/mysqld.sock" \
		--volumes-from=postgres \
		--volumes-from=mariadb \
		-v `pwd`/rails:/usr/src/rails \
		rails-dev /bin/bash -c " \
		cd activerecord ; \
		bundle exec rake db:create ; \
		bundle exec rake db:mysql:build ; \
		bundle exec rake db:postgresql:build"

run-test: ## Run rails tests in the rails-dev docker-image towards services in docker-compose
	docker run -i --network rails-dev \
		--env REDIS_URL="redis://redis:6379/" \
		--env MEMCACHE_SERVERS="memcached:11211" \
		--env MYSQL_HOST=mariadb \
		--env MYSQL_SOCK="/run/mysqld/mysqld.sock" \
		--volumes-from=postgres \
		--volumes-from=mariadb \
		-v `pwd`/rails:/usr/src/rails \
		rails-dev bundle exec rake test

run-test-verbose: ## Run rails tests in the rails-dev docker-image towards services in docker-compose
	docker run -i --network rails-dev \
		--env REDIS_URL="redis://redis:6379/" \
		--env MEMCACHE_SERVERS="memcached:11211" \
		--env MYSQL_HOST=mariadb \
		--env MYSQL_SOCK="/run/mysqld/mysqld.sock" \
		--env TESTOPTS="--verbose" \
		--volumes-from=postgres \
		--volumes-from=mariadb \
		-v `pwd`/rails:/usr/src/rails \
		rails-dev bundle exec rake test

help: ## Display this output.
	@egrep '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-20s\033[0m %s\n", $$1, $$2}'

.PHONY: clean help lint clone pull docker-build docker-compose-up get-shell setup-mysql-user setup-db run-test
.DEFAULT_GOAL := help
