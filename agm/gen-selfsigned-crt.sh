openssl req \
-nodes -days 365 -sha256 \
-subj '/C=AU/ST=Victoria/L=Melbourne/CN=AGM710B' \
-newkey rsa:2048 -keyout mycert.key -out mycert.csr

openssl req -in mycert.csr -noout -text
openssl req -in mycert.csr -noout -text -subject
openssl req -in mycert.csr -noout -text | grep DNS
