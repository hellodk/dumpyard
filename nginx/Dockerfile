FROM nginx:latest
RUN apt-get update \
    && apt-get install apache2-utils -y
COPY index.html /usr/share/nginx/html/
COPY .htpasswd /etc/nginx
COPY default.conf /etc/nginx/conf.d/
EXPOSE 80
