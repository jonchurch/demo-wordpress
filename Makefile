packages:
	apt-get update
	apt-get install -y mysql-client rsync

wpconfig:
	/bin/echo -e "<?php\ndefine('DB_NAME','demo');\ndefine('DB_USER','tugboat');\ndefine('DB_PASSWORD','tugboat');\ndefine('DB_HOST','mysql');" > ${TUGBOAT_ROOT}/docroot/wp-config.local.php

createdb:
	mysql -h mysql -u tugboat -ptugboat -e "create database demo;"

importdb:
	curl -L "https://www.dropbox.com/s/sabj5vq711bhst2/demo-wordpress-database.sql.gz?dl=0" > /tmp/database.sql.gz
	zcat /tmp/database.sql.gz | mysql -h mysql -u tugboat -ptugboat demo

importuploads:
	curl -L "https://www.dropbox.com/s/ufn5e3qe3sisdks/demo-wordpress-uploads.tar.gz?dl=0" > /tmp/uploads.tar.gz
	tar -C /tmp -zxf /tmp/uploads.tar.gz
	rsync -av --delete /tmp/uploads/ ${TUGBOAT_ROOT}/docroot/wp-content/uploads/

cleanup:
	apt-get clean
	rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

tugboat-init: packages wpconfig createdb importdb importuploads cleanup
tugboat-update: importdb importuploads cleanup
