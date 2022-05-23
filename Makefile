
docker-build:
	docker buildx build . -t meyerkev248/trm-takehome
up:
	docker-compose up -d
down:
	docker-compose down
sh:
	docker-compose run -p 4000:5000 --rm trm-app bash 
sh-attach:
	docker-compose exec trm-app bash 
