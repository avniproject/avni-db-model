su:=$(shell id -un)

deps:
	yarn install

setup:
	yarn add @dbml/cli
	yarn add dbdocs
	npm i @polarislabs/pg-to-dbml

generate-dbml-from-db:
	pg-to-dbml -c postgresql://openchs:password@localhost:5432 --db=openchs_test -s public -o=.

create-dbdocs-view:
	echo main-database | pbcopy
	dbdocs build ./avni.dbml
