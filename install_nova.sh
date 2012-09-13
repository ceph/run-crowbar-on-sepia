#!/bin/sh

/opt/dell/bin/barclamp_install.rb nova/ --force
find -L /tftpboot -type l -print0 |xargs -0 rm
cd /tftpboot/gemsite; gem generate_index
cd /tftpboot/ubuntu-12.04/crowbar-extra/
dpkg-scanpackages . |gzip -9 > Packages.gz
cd nova
dpkg-scanpackages . |gzip -9 > Packages.gz
knife 'node:*' ssh apt-get update
exit
