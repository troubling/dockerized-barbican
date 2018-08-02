# dockerized-barbican
Barbican Docker instance for Hummingbird All In One (HAIO)

```
$ cd <path-to-this-repo>
$ sudo make
... lots of output while it installs and sets everything up ...
... should end with something like:
Successfully built b386ed5711d0
docker run -t -d -h 127.0.0.1 -p 0.0.0.0:9311:9311 -v /etc/localtime:/etc/localtime --restart unless-stopped --name barbican barbican
20b7077427beac6a69562260be7dc62c3cc66f9105b2253bdd67799f5723be77
$
```

You should now have a `noauth` set up of Barbican going. Try:

```
$ make examplerequest
curl -i -X POST -H "X-Auth-Token: token" -H "Content-type: application/json" -H "X-Project-Id: test" -d '{"payload": "my-secret-here", "payload_content_type": "text/plain"}' http://localhost:9311/v1/secrets ; echo
HTTP/1.1 201 Created
Date: Thu, 02 Aug 2018 21:40:56 GMT
Server: Apache/2.4.18 (Ubuntu)
x-openstack-request-id: req-dd7c3fdf-0c47-4bbd-a79a-32aea4c1bacd
Location: http://localhost:9311/v1/secrets/45100c0a-6f9e-4853-96a9-3521a43f6d07
Content-Length: 87
Content-Type: application/json; charset=UTF-8

{"secret_ref": "http://localhost:9311/v1/secrets/45100c0a-6f9e-4853-96a9-3521a43f6d07"}
$
```

To integrate with an existing Keystone, do the following, changing the IP to your Keystone IP:

```
$ sudo make keystone IP=192.168.0.10
docker exec -it barbican /bin/sed -e 's,/v1: barbican_api,/v1: barbican-api-keystone,'  -e 's,identity_uri = http://localhost:35357,identity_uri = http://192.168.0.10:35357,' -e 's,admin_tenant_name = service,admin_tenant_name = test,' -e 's,admin_user = barbican,admin_user = tester,' -e 's,admin_password = orange,admin_password = testing,' -i /etc/barbican/barbican-api-paste.ini
docker exec -it barbican /usr/sbin/service barbican-worker restart
 * Restarting OpenStack Barbican Key Management Workers barbican-worker                                                      [ OK ]
 docker exec -it barbican /usr/sbin/service apache2 restart
  * Restarting Apache httpd web server apache2
  AH00558: apache2: Could not reliably determine the server's fully qualified domain name, using 127.0.0.1. Set the 'ServerName' directive globally to suppress this message
                                                                                                                             [ OK ]
$
```

And now, the noauth example request should no longer work:

```
$ make examplerequest
curl -i -X POST -H "X-Auth-Token: token" -H "Content-type: application/json" -H "X-Project-Id: test" -d '{"payload": "my-secret-here", "payload_content_type": "text/plain"}' http://localhost:9311/v1/secrets ; echo
HTTP/1.1 401 Unauthorized
Date: Thu, 02 Aug 2018 21:44:25 GMT
Server: Apache/2.4.18 (Ubuntu)
WWW-Authenticate: Keystone uri='http://192.168.0.10:35357'
Content-Length: 23
Content-Type: text/html; charset=UTF-8

Authentication required
$
```

So, get a valid Keystone token and work from there:

```
$ nectar auth
Account URL: http://127.0.0.1:8080/v1/AUTH_0b2054a94ee34f04a62ec2c1d52d076f
Token: 13aba941af484c0cbdf462698dae2e92
$ curl -i -X POST -H "X-Auth-Token: 13aba941af484c0cbdf462698dae2e92" -H "Content-type: application/json" -H "X-Project-Id: test" -d '{"payload": "my-secret-here", "payload_content_type": "text/plain"}' http://localhost:9311/v1/secrets ; echo
HTTP/1.1 201 Created
Date: Thu, 02 Aug 2018 21:46:01 GMT
Server: Apache/2.4.18 (Ubuntu)
x-openstack-request-id: req-6dcf5426-8832-4ed4-bd6f-165f34d8d2fb
Location: http://localhost:9311/v1/secrets/bd35f5a5-5425-45d3-9097-cfa384da8ca0
Content-Length: 87
Content-Type: application/json; charset=UTF-8

{"secret_ref": "http://localhost:9311/v1/secrets/bd35f5a5-5425-45d3-9097-cfa384da8ca0"}
$
```

