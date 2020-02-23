#!/bin/bash
if [ "$DATABASE_URL" ]; then
  git clone https://git.tt-rss.org/fox/tt-rss.git

  echo "Injecting configuration file..."
  cp ttrss-config.php tt-rss/config.php

  echo "Fixing permissions..."
  chmod -R -w tt-rss
  chmod +w tt-rss/plugins.local
  chmod -R 777 tt-rss/cache tt-rss/lock tt-rss/feed-icons

  echo "Checking database..."
  if ! psql "$DATABASE_URL" -c 'SELECT schema_version FROM ttrss_version' &>/dev/null; then
      echo "Initializing database..."
      psql "$DATABASE_URL" < tt-rss/schema/ttrss_schema_pgsql.sql >/dev/null
  fi

  echo "Installing plugins"
  php plugins-installer.php

  if [ "$TTRSS_ADMIN_PASSWORD" ]; then
    $ttrss_admin_password=$(php -r "echo 'SHA1:'.sha1(getenv('TTRSS_ADMIN_PASSWORD'));")
    echo "admin password hash: ${ttrss_admin_password}"
  fi
else
  echo "go add a Postgres database addon"
  return 1
fi
