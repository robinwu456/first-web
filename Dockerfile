FROM quay.io/robinwu456/alpine:3.15.4
COPY busybox-x86_64 /
COPY info.cgi /
COPY the7 /
RUN \
  apk update && \
  apk add --no-cache nano sudo bash wget curl git tree grep && \
  chmod +x busybox-x86_64 && \
  chmod +x info.cgi && \
  mv busybox-x86_64 bin/busybox1.28 && \
  mkdir -p /opt/www/cgi-bin && echo "let me go 2" > /opt/www/index.html && \
  cp -r /the7/* /opt/www/ && \
  cp info.cgi /opt/www/cgi-bin/info

ENTRYPOINT ["/bin/busybox1.28"]
CMD ["httpd", "-f", "-h", "/opt/www"]

