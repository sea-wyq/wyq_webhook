#!/bin/bash 

service=$1
secret=$3
namespace=$2 
tmpdir=certs

cat <<EOF >> ${tmpdir}/csr.conf 
[req] 
req_extensions = v3_req 
distinguished_name = req_distinguished_name 

[req_distinguished_name] 
O = hw.dev/serving 
CN = ${service}.${namespace}.svc 

[ v3_req ] 
basicConstraints = CA:FALSE 
keyUsage = nonRepudiation, digitalSignature, keyEncipherment 
extendedKeyUsage = serverAuth 
subjectAltName = @alt_names 

[alt_names] 
DNS.1 = ${service} 
DNS.2 = ${service}.${namespace} 
DNS.3 = ${service}.${namespace}.svc 
IP.1 = 192.168.0.1 
EOF

#生成CA私钥和ca根证书 
openssl genrsa -out ca.key 2048 
openssl req -x509 -new -nodes -key ca.key -subj "/CN=${service}.${namespace}.svc" -days 10000 -out ca.crt 

#生成服务端私钥和证书签名请求，apiserver通过https访问准入webhook，需要服务端证书 
openssl genrsa -out ${service}.key 2048 
openssl req -new -key ${service}.key -subj "/CN=${service}.${namespace}.svc" -out ${tmpdir}/${service}.csr -config ${tmpdir}/csr.conf 

#用CA私钥和根证书签发服务端证书 
openssl x509 -req -CA ca.crt -CAkey ca.key -CAcreateserial -in ${tmpdir}/${service}.csr -days 10000 -out ${service}.crt -extfile ${tmpdir}/csr.conf -extensions v3_req 
