#!/usr/bin/env bash
set -e

source /vagrant/utils/defaults.sh
source /vagrant/utils/helpers.sh
sudo apt-get update
sudo apt-get install curl tar -y   
check_requirements curl tar

ARCHIVE="alertmanager-${ALERTMANAGER_VERSION}.linux-amd64.tar.gz"

if ! check_cache "${ARCHIVE}"; then
  get_archive "https://github.com/prometheus/alertmanager/releases/download/v${ALERTMANAGER_VERSION}/${ARCHIVE}"
fi

if ! id alertmanager > /dev/null 2>&1 ; then
  useradd --system alertmanager
fi

TMPD=$(mktemp -d)
tar zxf "${CACHE_PATH}/${ARCHIVE}" -C $TMPD --strip-components=1

install -m 0755 $TMPD/{alertmanager,amtool} /vagrant/exercise01/configs/alertmanager/alertdump /usr/bin/
install -d -o alertmanager -g alertmanager /var/lib/alertmanager
install -m 0644 /vagrant/exercise01/configs/alertmanager/{alertmanager,alertdump}.service /etc/systemd/system/
install -m 0644 -D /vagrant/exercise01/configs/alertmanager/alertmanager.yml /etc/alertmanager/alertmanager.yml

systemctl daemon-reload

systemctl enable alertmanager
systemctl start alertmanager

systemctl enable alertdump
systemctl start alertdump
