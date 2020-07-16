FROM fluent/fluentd
RUN   apk add --update --virtual .build-deps sudo build-base ruby-dev
     # && mkdir /data/ \
     # && mkdir /data/td-agent
RUN ["gem", "install", "fluent-plugin-mongo"]
COPY fluentd.conf /fluentd/etc/fluent.conf  
