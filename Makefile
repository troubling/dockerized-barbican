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

prune:
	docker system prune -a

bash:
	docker exec -it barbican /bin/bash

examplerequest:
	curl -i -X POST -H "X-Auth-Token: token" -H "Content-type: application/json" -H "X-Project-Id: test" -d '{"payload": "my-secret-here", "payload_content_type": "text/plain"}' http://localhost:9311/v1/secrets ; echo

keystone:
	docker exec -it barbican /bin/sed -e 's,/v1: barbican_api,/v1: barbican-api-keystone,'  -e 's,identity_uri = http://localhost:35357,identity_uri = http://${IP}:35357,' -e 's,admin_tenant_name = service,admin_tenant_name = test,' -e 's,admin_user = barbican,admin_user = tester,' -e 's,admin_password = orange,admin_password = testing,' -i /etc/barbican/barbican-api-paste.ini
	docker exec -it barbican /usr/sbin/service barbican-worker restart
	docker exec -it barbican /usr/sbin/service apache2 restart

bootstrap: build run
