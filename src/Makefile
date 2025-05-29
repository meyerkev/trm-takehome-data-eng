
docker-build:
	docker buildx build . -t 386145735201.dkr.ecr.us-east-2.amazonaws.com/trm-takehome
up:
	docker-compose up -d
down:
	docker-compose down
sh:
	docker-compose run -p 4000:5000 --rm trm-app
sh-attach:
	docker-compose exec trm-app bash 
push: 
	docker push 386145735201.dkr.ecr.us-east-2.amazonaws.com/trm-takehome
