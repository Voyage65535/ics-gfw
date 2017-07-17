#!/bin/sh

prefix=`pip show shadowsocks | awk '/Location:/ {print$2}'`
sed -i 's/EVP_CIPHER_CTX_cleanup/EVP_CIPHER_CTX_reset/g' "${prefix}/shadowsocks/crypto/openssl.py"

