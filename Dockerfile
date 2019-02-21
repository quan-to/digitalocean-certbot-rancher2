FROM python:2-alpine3.9

EXPOSE 80 443
VOLUME /etc/letsencrypt /var/lib/letsencrypt
WORKDIR /opt/certbot

ENV DOMAINS ""
ENV ENVIRONMENT "staging"
ENV EMAIL ""
ENV CERTNAME "letsencrypt"

# Install kubectl
ADD https://storage.googleapis.com/kubernetes-release/release/v1.6.4/bin/linux/amd64/kubectl /bin/kubectl

RUN apk add --no-cache --virtual .certbot-deps \
        libffi \
        libssl1.1 \
        openssl \
        ca-certificates \
        binutils

RUN apk add --no-cache --virtual .build-deps \
        gcc \
        linux-headers \
        openssl-dev \
        musl-dev \
        libffi-dev \
    && pip install --no-cache-dir certbot certbot-dns-digitalocean

COPY update.sh /opt/certbot/update.sh

RUN chmod +x /opt/certbot/update.sh
RUN chmod +x /bin/kubectl

CMD /opt/certbot/update.sh