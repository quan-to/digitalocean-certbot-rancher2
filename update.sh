#!/bin/sh

SDOMAINS=$(echo "$DOMAINS" | tr "," "\n")
DOMAINLINE=""

for domain in $SDOMAINS;
do
	echo "Adding $domain to list"
	DOMAINLINE="$DOMAINLINE -d $domain"
done

if [[ $ENVIRONMENT != "production" ]]; then
  DOMAINLINE="$DOMAINLINE --staging"
fi

echo "Calling Certbot for $DOMAINS"
certbot certonly --agree-tos -n -m $EMAIL --dns-digitalocean --dns-digitalocean-credentials $CREDFILE $DOMAINLINE

if [[ $? == 0 ]]; then
  cd /etc/letsencrypt/live/

  FOLDER=`ls -d -- */`

  cd $FOLDER
  echo "Updating cert at $CERTNAME"
  kubectl create secret tls "$CERTNAME" --key "privkey.pem" --cert "fullchain.pem" --dry-run -o yaml | kubectl apply -f -
else
  echo "Error on certbot. Skipping certificate update."
fi
