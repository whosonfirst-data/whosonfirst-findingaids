DOCKERARGS=--platform=linux/amd64 --no-cache

docker:
	docker buildx build $(DOCKERARGS) -t whosonfirst-data-findingaid -f Dockerfile .
