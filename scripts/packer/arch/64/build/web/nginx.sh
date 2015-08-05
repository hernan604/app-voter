#!/bin/bash
echo '==> installing nginx'
pacman -Sy --noconfirm
pacman -S --noconfirm nginx
mkdir /etc/nginx

cat <<'NGINX_CONFIG' > /etc/nginx/nginx.conf
#user html;
worker_processes  2;

#error_log  logs/error.log;
#error_log  logs/error.log  notice;
#error_log  logs/error.log  info;

#pid        logs/nginx.pid;


events {
    worker_connections  1024;
}


http {
    include       mime.types;
    default_type  application/octet-stream;

    #log_format  main  '$remote_addr - $remote_user [$time_local] "$request" '
    #                  '$status $body_bytes_sent "$http_referer" '
    #                  '"$http_user_agent" "$http_x_forwarded_for"';

    #access_log  logs/access.log  main;

    sendfile        on;
    #tcp_nopush     on;

    #keepalive_timeout  0;
    keepalive_timeout  65;

    #gzip  on;

    upstream myapp {
     #server 127.0.0.1:8080;
     #least_conn;
      server 192.168.5.120:8080;
      server 192.168.5.121:8080;
      server 192.168.5.122:8080;
      server 192.168.5.123:8080;
      server 192.168.5.124:8080;
      server 192.168.5.125:8080;
      server 192.168.5.126:8080;
      server 192.168.5.127:8080;
    }
    server {
      listen 80;
      server_name localhost;
      location / {
        proxy_pass http://myapp;
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection "upgrade";
        proxy_set_header Host $host;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
      }
    }
}

NGINX_CONFIG

echo '==> enable nginx'
systemctl enable nginx
systemctl start nginx
