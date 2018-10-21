#!/bin/bash

# AGM creating a CSR in /etc/localkeys/agmtest.csr , 
# the private key is in /etc/localkeys/agmtest.key
#

# create the directory if /etc/localkeys doesn't exist
mkdir -p /etc/localkeys

# make a backup copy of /act/certs/nginx.*
if [ ! -f /etc/localkeys/nginx.cert ]; then cp /act/certs/nginx.cert /etc/localkeys/ ; fi
if [ ! -f /etc/localkeys/nginx.key ]; then cp /act/certs/nginx.key /etc/localkeys/ ; fi

echo "Location of the ssl certificate for nGinx server - /act/emsrv/nginx_server.conf config file"
grep ssl_certificate /act/emsrv/nginx_server.conf 

set -x
openssl req -new -sha256 -nodes -out /etc/localkeys/agmtest.csr -newkey rsa:2048 -keyout /etc/localkeys/agmtest.key -config <(
cat <<-EOF
[req]
default_bits = 2048
prompt = no
default_md = sha256
req_extensions = v3_req
distinguished_name = dn
 
[ dn ]
C=AU
ST=Victoria
L=Melbourne
O=Acme
OU=ITSecurity
CN=agmtest
emailAddress=johndoe@acme.com
 
[ v3_req ]
# Extensions to add to a certificate request
basicConstraints = CA:FALSE
keyUsage = nonRepudiation, digitalSignature, keyEncipherment
subjectAltName = @alt_names
 
[ alt_names ]
DNS.1 = agmtest
DNS.2 = agmtest.acme.com
IP.1 = 10.65.5.214
EOF
)

openssl req -in /etc/localkeys/agmtest.csr -noout -text
openssl req -in /etc/localkeys/agmtest.csr -noout -text -verify
openssl req -in /etc/localkeys/agmtest.csr -noout -text -subject
openssl req -in /etc/localkeys/agmtest.csr -noout -text | grep DNS

ls -la /etc/localkeys
