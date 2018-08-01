#!/bin/bash

service barbican-worker restart
service apache2 restart

#keep this container running
tail -f /dev/null
