su:=$(shell id -un)

setup:
	yarn global add @dbml/cli
	yarn global add dbdocs
	npm i -g @polarislabs/pg-to-dbml

generate-db-dump:
	-rm dump.sql
	sudo -u $(su) pg_dump openchs -n public -s > dump.sql

generate-dbml:
	sql2dbml dump.sql --postgres -o avni.dbml

generate-dbml-from-db:
	pg-to-dbml -c postgresql://vsingh:password@localhost:5432 --db=openchs -s public -o=.

create-dbdocs-view:
	dbdocs build ./avni.dbml