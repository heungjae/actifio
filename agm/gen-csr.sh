#!/bin/bash

# AGM creating a CSR in /etc/localkeys/aupr4ap01acmeai.csr , 
# the private key is in /etc/localkeys/aupr4ap01acmeai.key
#
set -x
openssl req -new -sha256 -nodes -out /etc/localkeys/aupr4ap01acmeai.csr -newkey rsa:2048 -keyout /etc/localkeys/aupr4ap01acmeai.key -config <(
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
CN=AGM710B
emailAddress=johndoe@acme.com
 
[ v3_req ]
# Extensions to add to a certificate request

basicConstraints = CA:FALSE
keyUsage = nonRepudiation, digitalSignature, keyEncipherment
subjectAltName = @alt_names
 
[ alt_names ]
DNS.1 = aupr4ap01acmeai
DNS.2 = ActifioGM.aus.theacme.com
DNS.3 = ActifioGM
DNS.4 = aupr4ap01acmeai.aur.acme.com.au
IP.1 = 10.65.5.126
EOF
)
