#!/bin/bash

file=backup-dir.tar.gz
dir=backup-dir

echo "Comprimiendo directorio ${dir}..."

tar czf ${file} ${dir}

echo "Archivo ${file} comprimido."

bucket=backup-dir-example
resource="/${bucket}/${file}"
contentType="application/x-compressed-tar"
dateValue=`date -R`
stringToSign="PUT\n\n${contentType}\n${dateValue}\n${resource}"
s3Key=XXXXXXXXXX
s3Secret=XXXXXXXXXXXX

echo "Generando firma para la solicitud..."
signature=`echo -en ${stringToSign} | openssl sha1 -hmac ${s3Secret} -binary | base64`

echo "Subiendo el archivo ${file} al bucket ${bucket}..."
curl -X PUT -T "${file}" \
  -H "Host: ${bucket}.s3.amazonaws.com" \
  -H "Date: ${dateValue}" \
  -H "Content-Type: ${contentType}" \
  -H "Authorization: AWS ${s3Key}:${signature}" \
  https://${bucket}.s3.amazonaws.com/${file}

if [ $? -eq 0 ]; then
  echo "Subida exitosa."
else
  echo "Error en la subida."
fi
