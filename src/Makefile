AWS_ACCOUNT_ID ?= 386145735201
AWS_REGION ?= us-east-2
IMAGE_TAG ?= latest

.PHONY: docker-build up down reset sh sh-attach push logs
docker-build:
	docker buildx build . -t $(AWS_ACCOUNT_ID).dkr.ecr.$(AWS_REGION).amazonaws.com/trm-takehome:$(IMAGE_TAG)
up:
	docker-compose up -d
down:
	docker-compose down
reset: down up
sh:
	docker-compose run -p 4000:5000 --rm trm-app
sh-attach:
	docker-compose exec trm-app bash 
push: 
	docker push $(AWS_ACCOUNT_ID).dkr.ecr.$(AWS_REGION).amazonaws.com/trm-takehome:$(IMAGE_TAG)
logs:
	docker-compose logs -f

