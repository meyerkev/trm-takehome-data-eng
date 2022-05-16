
docker-build:
	docker buildx build . -t trm-takehome
up:
	docker-compose up -d
down:
	docker-compose down
sh:
	docker-compose run -p 5000:5000 --rm trm-takehome bash 
sh-attach:
	docker-compose exec trm-app bash 
