FROM fluent/fluentd:stable-debian

RUN buildDeps="sudo make gcc g++ libc-dev ruby-dev" \
 && apt-get update \
 && apt-get install -y --no-install-recommends $buildDeps \
 && sudo gem install \
        fluent-plugin-elasticsearch fluent-plugin-mongo \
 && sudo gem sources --clear-all \
 && fluent-gem install fluent-plugin-mongo \
 && SUDO_FORCE_REMOVE=yes \
    apt-get purge -y --auto-remove \
                  -o APT::AutoRemove::RecommendsImportant=false \
                  $buildDeps \
 && rm -rf /var/lib/apt/lists/* \
           /home/fluent/.gem/ruby/2.3.0/cache/*.gem

#RUN apt-get update && \
#    apt-get install -y build-essential make autoconf ruby-dev

#RUN fluent-gem install fluent-plugin-mongo

