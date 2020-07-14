su:=$(shell id -un)

setup:
	yarn global add @dbml/cli
	yarn global add dbdocs

generate-db-dump:
	-rm dump.sql
	sudo -u $(su) pg_dump openchs -n public -s > dump.sql

generate-dbml:
	sql2dbml dump.sql --postgres -o avni.dbml

create-dbdocs-view:
	dbdocs build ./avni.dbml