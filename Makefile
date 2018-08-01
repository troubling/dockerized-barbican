all: bootstrap

build:
	docker build -t barbican .

run:
	docker run -t -d -h 127.0.0.1 -p 0.0.0.0:9311:9311 -v /etc/localtime:/etc/localtime --restart unless-stopped --name barbican barbican

restart:
	docker start barbican

stop:
	docker ps | grep barbican | awk '{ print $$1 }' | xargs docker stop

kill:
	docker ps | grep barbican | awk '{ print $$1 }' | xargs docker kill > /dev/null
	docker ps -a | grep barbican | awk '{ print $$1 }' | xargs docker rm -v > /dev/null

purge:
	docker system prune -a

bash:
	docker exec -it barbican /bin/bash

examplerequest:
	curl -i -X POST -H "X-Auth-Token: token" -H "Content-type: application/json" -H "X-Project-Id: test" -d '{"payload": "my-secret-here", "payload_content_type": "text/plain"}' http://localhost:9311/v1/secrets ; echo

bootstrap: build run
