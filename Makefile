#
# Создание шаблона БД на отдельном сервере БД (без dcape)
# template database Makefile
#
SHELL               = /bin/bash
CFG                 = .env

DB_NAME            ?= tpro-template
DB_LOCALE          ?= ru_RU.UTF-8


#PG_MAJOR
PG_MAJOR           ?= 11

# Postgres shared folder
PG_SHARE           ?= /usr/share/postgresql/


define CONFIG_DEF
# ------------------------------------------------------------------------------
# pg-skel settings

# Template database name
DB_NAME=$(DB_NAME)

# Template database locale
DB_LOCALE=$(DB_LOCALE)

#PG_MAJOR
PG_MAJOR=$(PG_MAJOR)

# Postgres shared folder
PG_SHARE=$(PG_SHARE)

endef
export CONFIG_DEF

# ------------------------------------------------------------------------------

-include $(CFG)
export

.PHONY: all $(CFG) start start-hook stop update docker-wait db-create db-drop help

##
## Цели:
##

all: help

# ------------------------------------------------------------------------------
# webhook commands

start: db-create

start-hook: db-create

stop: db-drop

update: db-create

# ------------------------------------------------------------------------------
# docker

# Wait for postgresql container start
pg-wait:
	@echo -n "Checking PG is ready..."
	@until [[ `systemctl is-active postgresql` == active ]] ; do sleep 1 ; echo -n "." ; done
	@echo "Ok"

# ------------------------------------------------------------------------------
# DB operations

## create db and load sql
db-create: pg-wait
	@echo "*** $@ ***" ; \
	cp -r ./fts/tsearch_data $$PG_SHARE/$$PG_MAJOR/ ; \
	[[ "$$DB_LOCALE" ]] && DB_LOCALE="-l $$DB_LOCALE" ; \
	echo "Creating $$DB_NAME..." && \
	sudo -u postgres createdb -T template0 $$DB_LOCALE $$DB_NAME || db_exists=1 ; \
	if [[ ! "$$db_exists" ]] ; then \
	  cat setup.sql | psql -U postgres -d $$DB_NAME -f - ; \
	fi

## drop database
db-drop: docker-wait
	@echo "*** $@ ***"
	@sudo -u postgres psql -c "UPDATE pg_database SET datistemplate = FALSE WHERE datname = '$$DB_NAME';"
	@psql -U postgres -c "DROP DATABASE \"$$DB_NAME\";" || true

# ------------------------------------------------------------------------------

## create initial config
$(CFG):
	@echo "$$CONFIG_DEF" > $@

# ------------------------------------------------------------------------------

## List Makefile targets
help:
	@grep -A 1 "^##" Makefile | less

##
## Press 'q' for exit
##
