#!/bin/bash
#
# Use this script to clone repositories
#

IP=10.10.254.1
REPOURL="https://mirror.bytemark.co.uk/centos/7"
BASEREPO="$REPOURL/os/x86_64"
UPDATESREPO="$REPOURL/updates/x86_64"
EXTRASREPO="$REPOURL/extras/x86_64"

mkdir /opt/flight/deployment/repo/

cat << EOF > /opt/flight/deployment/repo/mirror.conf
[main]
cachedir=/var/cache/yum/\$basearch/\$releasever
keepcache=0
debuglevel=2
logfile=/var/log/yum.log
exactarch=1
obsoletes=1
gpgcheck=1
plugins=1
installonly_limit=5
bugtracker_url=http://bugs.centos.org/set_project.php?project_id=23&ref=http://bugs.centos.org/bug_report_page.php?category=yum
distroverpkg=centos-release
http_caching=packages
reposdir=/dev/null
[centos-7-base]
name=centos-7-base
baseurl=$BASEREPO
description=No description specified
enabled=1
skip_if_unavailable=1
gpgcheck=0
priority=10

[centos-7-updates]
name=centos-7-updates
baseurl=$UPDATESREPO
description=No description specified
enabled=1
skip_if_unavailable=1
gpgcheck=0
priority=10

[centos-7-extras]
name=centos-7-extras
baseurl=$EXTRASREPO
description=No description specified
enabled=1
skip_if_unavailable=1
gpgcheck=0
priority=10

[epel-7]
name=epel-7
baseurl=https://dl.fedoraproject.org/pub/epel/7/x86_64/
description=No description specified
enabled=1
skip_if_unavailable=1
gpgcheck=0
priority=1

[alcesflight]
name=AlcesFlight - Base
baseurl=https://alces-flight.s3-eu-west-1.amazonaws.com/repos/alces-flight/centos/$releasever/$basearch/
enabled=1
gpgcheck=0

[openflight]
name=OpenFlight - Base
baseurl=https://repo.openflighthpc.org/openflight/centos/$releasever/$basearch/
enabled=1
gpgcheck=0
EOF

cat << EOF > /opt/flight/deployment/repo/cluster.repo
[centos-7-base]
name=centos-7-base
baseurl=http://$IP/deployment/repo/centos-7-base
description=No description specified
enabled=1
skip_if_unavailable=1
gpgcheck=0
priority=10

[centos-7-updates]
name=centos-7-updates
baseurl=http://$IP/deployment/repo/centos-7-updates
description=No description specified
enabled=1
skip_if_unavailable=1
gpgcheck=0
priority=10

[centos-7-extras]
name=centos-7-extras
baseurl=http://$IP/deployment/repo/centos-7-extras
description=No description specified
enabled=1
skip_if_unavailable=1
gpgcheck=0
priority=10

[epel-7]
name=epel-7
baseurl=http://$IP/deployment/repo/epel-7
description=No description specified
enabled=1
skip_if_unavailable=1
gpgcheck=0
priority=5

[alcesflight]
name=AlcesFlight - Base
baseurl=http://$IP/deployment/repo/alcesflight
enabled=1
gpgcheck=0
priority=4

[openflight]
name=OpenFlight - Base
baseurl=http://$IP/deployment/repo/openflight
enabled=1
gpgcheck=0
priortiy=4
EOF

cd /opt/flight/deployment/repo/

for i in centos-7-updates centos-7-extras epel-7 alcesflight openflight ; do 
    reposync -nm --config mirror.conf -r $i -p $i --norepopath
    createrepo $i
done

reposync -nm --config mirror.conf -r centos-7-base -p centos-7-base --norepopath

mkdir -p centos-7-base/images/pxeboot
wget -O centos-7-base/images/pxeboot/vmlinuz $BASEREPO/images/pxeboot/vmlinuz
wget -O centos-7-base/images/pxeboot/initrd.img $BASEREPO/images/pxeboot/initrd.img

createrepo -g comps.xml centos-7-base

