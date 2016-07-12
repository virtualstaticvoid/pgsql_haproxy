.DEFAULT_GOAL := build

build:
	docker build -t vsv/postgres pgsql
	docker-compose build

run:
	docker-compose up -d loadbalancer

test:
	pg_isready -h 172.36.5.1 -p 5488     # proxy
	pg_isready -h 172.36.5.16            # master
	pg_isready -h 172.36.5.17            # slave1
	pg_isready -h 172.36.5.18            # slave2

pgsqlchk:
	curl http://172.36.5.16:23267 # master
	@echo
	curl http://172.36.5.17:23267 # slave1
	@echo
	curl http://172.36.5.18:23267 # slave2
	@echo

watch:
	docker-compose logs -f

monitor:
	@echo Username: admin
	@echo Password: passwordhere
	@gnome-open http://172.36.5.1:9000/haproxy_stats
