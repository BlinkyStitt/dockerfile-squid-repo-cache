# TODO: move this to 01_infra and move alpine, ubuntu, fedora to 02_more_base
# TODO: no need for s6 on this. just run squid for localhost builds
FROM bwstitt/ubuntu:17.10

EXPOSE 8000

VOLUME /var/cache/squid-deb-proxy /var/log/squid-deb-proxy

RUN docker-install squid-deb-proxy

RUN set -eux; \
    \
    conf=/etc/squid-deb-proxy/squid-deb-proxy.conf; \
    \
    echo 'cache_effective_user proxy' >>"$conf"; \
    echo 'refresh_pattern apk$   129600 100% 129600' >>"$conf"; \
    echo 'refresh_pattern iso$   129600 100% 129600' >>"$conf"; \
    echo 'refresh_pattern rpm$   129600 100% 129600' >>"$conf"; \
    echo 'refresh_pattern whl$   129600 100% 129600' >>"$conf"; \
    echo 'cache_replacement_policy heap LFUDA' >>"$conf"; \
    \
    sed -e 's/^#\([cache\|http_access].*allow.*to_archive_mirrors$\)/\1/' -i "$conf"; \
    sed -e 's/^\([cache\|http_access].*deny.*to_archive_mirrors$\)/#\1/' -i "$conf"; \
    sed -e 's/maximum_object_size 512 MB/maximum_object_size 5 GB/' -i "$conf"; \
    sed -e 's/squid-deb-proxy 40000 16 256/squid-deb-proxy 500000 16 256/' -i "$conf"; \
    sed -e 's/visible_hostname squid-deb-proxy/visible_hostname squid-repo-cache/' -i "$conf"; \
    \
    cat $conf; \
    mkdir -p /var/log/squid-deb-proxy; \
    chown -R proxy:proxy /var/log/squid-deb-proxy

ENTRYPOINT ["/docker-entrypoint.sh"]
CMD ["squid3"]

COPY docker-entrypoint.sh /
COPY mirror-dstdomain.acl /etc/squid-deb-proxy/mirror-dstdomain.acl.d/99-local
