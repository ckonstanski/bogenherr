#!/bin/bash

echo 'APT::Acquire::Retries "3";' > /etc/apt/apt.conf.d/80-retries
export DEBIAN_FRONTEND=noninteractive
apt-get update
apt-get -y -o Dpkg::Options::="--force-confdef" -o Dpkg::Options::="--force-confold" dist-upgrade
apt-get -y install -o Dpkg::Options::="--force-confdef" -o Dpkg::Options::="--force-confold" aptitude
aptitude -y install -o Dpkg::Options::="--force-confdef" -o Dpkg::Options::="--force-confold" apt-transport-https ca-certificates software-properties-common language-pack-de
update-ca-certificates
aptitude update
aptitude -y install -o Dpkg::Options::="--force-confdef" -o Dpkg::Options::="--force-confold" sbcl sbcl-source leiningen dnsutils bind9-host vim curl wget rlwrap pass rsync sudo jq lsof zip unzip

rsync -av /data/ /

if (( OLO_UID != 0 )); then
    userdel ubuntu || true
    groupdel ubuntu || true
    rm -rf /home/ubuntu || true
    export HOMEDIR="/home/${OLO_USERNAME}"
    groupadd -g "${OLO_GID}" "${OLO_GROUPNAME}" || OLO_GROUPNAME=$(grep -F "x:${OLO_GID}:" /etc/group | awk -F: '{print $1}')
    useradd -s /bin/bash -m -u "${OLO_UID}" -g "${OLO_GROUPNAME}" "${OLO_USERNAME}" || OLO_USERNAME=$(grep -F "x:${OLO_UID}:" /etc/passwd | awk -F: '{print $1}')
    SUDOERS_FILENAME="${OLO_USERNAME//\./_}"
    echo "${OLO_USERNAME} ALL=(ALL) NOPASSWD: ALL" > "/etc/sudoers.d/${SUDOERS_FILENAME}"
    chmod 0440 "/etc/sudoers.d/${SUDOERS_FILENAME}"
    mkdir -p "${HOMEDIR}/.gnupg"
    chown "${OLO_USERNAME}":"${OLO_GROUPNAME}" "${HOMEDIR}/.gnupg"
    chmod 0700 "${HOMEDIR}/.gnupg"
fi

exit 0
