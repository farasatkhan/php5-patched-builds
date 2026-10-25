#!/usr/bin/env bash
# Run: bash collect-php-build-info.sh > php-build-info.txt

cat /etc/os-release
uname -m
getconf GNU_LIBC_VERSION
php -v
php -m

apache=$(command -v apache2ctl || command -v apachectl)
if [[ -n "$apache" ]]; then
    "$apache" -v
    printf '\n=== APACHE PHP / FASTCGI MODULES ===\n'
    "$apache" -M | grep -E 'php[0-9]*_module|proxy_fcgi_module|fcgid_module|fastcgi_module'
fi

printf '\n=== RUNNING PHP-FPM PROCESSES ===\n'
ps -eo comm= | grep -E '^php.*fpm' | sort -u

printf '\n=== APACHE CONFIG FILES WITH PHP HANDLERS ===\n'
grep -RlE '^[[:space:]]*(SetHandler|ProxyPassMatch|FcgidWrapper|AddHandler|Action)[[:space:]].*(fcgi|php)' \
    /etc/apache2/sites-enabled /etc/apache2/conf-enabled \
    /etc/httpd/conf /etc/httpd/conf.d 2>/dev/null
printf 'Module/process checks are clues; mod_php and FPM can coexist for different sites.\n'

if command -v nginx >/dev/null 2>&1; then
    nginx -v 2>&1
fi
