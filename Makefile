packages:
	apt-get update
	apt-get install -y mysql-client rsync
	curl -O https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar
	chmod +x wp-cli.phar
	mv wp-cli.phar /usr/local/bin/wp

wpconfig:
	/bin/echo -e "<?php\ndefine('DB_NAME','demo');\ndefine('DB_USER','tugboat');\ndefine('DB_PASSWORD','tugboat');\ndefine('DB_HOST','mysql');" > ${TUGBOAT_ROOT}/docroot/wp-config.local.php

createdb:
	mysql -h mysql -u tugboat -ptugboat -e "create database demo;"

importdb:
	curl -L "https://www.dropbox.com/s/sabj5vq711bhst2/demo-wordpress-database.sql.gz?dl=0" > /tmp/database.sql.gz
	zcat /tmp/database.sql.gz | mysql -h mysql -u tugboat -ptugboat demo
	wp --allow-root --path=/var/www/html search-replace 'wordpress.local' "${TUGBOAT_PREVIEW}-${TUGBOAT_TOKEN}.${TUGBOAT_DOMAIN}" --skip-columns=guid

importuploads:
	curl -L "https://www.dropbox.com/s/ufn5e3qe3sisdks/demo-wordpress-uploads.tar.gz?dl=0" > /tmp/uploads.tar.gz
	tar -C /tmp -zxf /tmp/uploads.tar.gz
	rsync -av --delete /tmp/uploads/ ${TUGBOAT_ROOT}/docroot/wp-content/uploads/

cleanup:
	apt-get clean
	rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

tugboat-init: packages wpconfig createdb importdb importuploads cleanup
tugboat-update: importdb importuploads cleanup
tugboat-build:
	wp --allow-root --path=/var/www/html search-replace "${TUGBOAT_BASE_PREVIEW}-${TUGBOAT_BASE_PREVIEW_TOKEN}.${TUGBOAT_DOMAIN}" "${TUGBOAT_PREVIEW}-${TUGBOAT_TOKEN}.${TUGBOAT_DOMAIN}" --skip-columns=guid
