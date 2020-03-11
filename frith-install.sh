#!/bin/bash
set -e

# We do some things as a normal user, then some things as root

if [[ $(whoami) != root ]]; then
    # Perform network operations as ordinary user
    TMPDIR=$(mktemp -d)
    wget -q https://andrewg.com/andrewg-codesign.pub -O $TMPDIR/andrewg-codesign.asc
    # Now call ourselves recursively
    sudo /usr/bin/env TMPDIR=$TMPDIR /bin/bash $0
elif [[ ! $TMPDIR && ! $1 ]]; then
    echo "Please don't run this script as root (i.e. with sudo)"
    exit 1
fi

PERSISTENT_VOL=/live/persistence/TailsData_unlocked
PERSISTENT_VOL_SETUP=/media/tails-persistence-setup/TailsData

if [[ -d $PERSISTENT_VOL_SETUP ]]; then
    # support early installation (i.e. no reboot after configuring persistence)
    cd $PERSISTENT_VOL_SETUP
elif [[ -d $PERSISTENT_VOL ]]; then
    cd $PERSISTENT_VOL
else
    echo "No persistent disk. Please ensure your persistent disk is configured and unlocked."
    exit 1
fi

# configure additional software persistence
# this is a custom persistence config to let us use non-standard APT repos
#
# NB this will overwrite any existing persistence configuration!

cat <<EOF > live-additional-software.conf
andrewgdotcom-keyring
frith
EOF

cat <<EOF > persistence.conf
/home/amnesia/Persistent	source=Persistent
/home/amnesia/.gnupg	source=gnupg
/var/cache/apt/archives	source=apt/cache
/var/lib/apt/lists	source=apt/lists
/etc/apt/sources.list.d	source=apt/sources.list.d,link
/etc/apt/trusted.gpg.d	source=apt/trusted.gpg.d,link
EOF

# Before we continue, trash any stale APT config. Frith is a jealous god.
# Also, he screwed up in the past and wants to repent.

rm -rf apt

# ensure the peristent directories are properly created

for i in apt/sources.list.d apt/trusted.gpg.d apt/lists apt/cache; do
  if [ ! -d $i ]; then
    mkdir -p $i
  fi
done

# if the user has not already enabled GPG persistence, we must prepopulate it

if [ ! -d gnupg ]; then
  cp -a /etc/skel/.gnupg gnupg
  chown -R amnesia:amnesia gnupg
fi

# fix permissions

chown tails-persistence-setup:tails-persistence-setup live-additional-software.conf persistence.conf
chmod og= live-additional-software.conf persistence.conf

cat <<EOF > apt/sources.list.d/andrewg.list
deb tor+http://andrewg.com/debian andrewg main
EOF

gpg --no-default-keyring --keyring=apt/trusted.gpg.d/andrewg-codesign-temp.gpg --import $TMPDIR/andrewg-codesign.asc
# This might leave a backup file; clean it up
rm "apt/trusted.gpg.d/andrewg-codesign.gpg~" || true

if [[ -d $PERSISTENT_VOL_SETUP ]]; then
    # during early installation, persistent storage must be manually activated
    umount /var/cache/apt/archives || true
    mount -o bind $PWD/apt/cache /var/cache/apt/archives
    umount /var/lib/apt/lists || true
    mount -o bind $PWD/apt/lists /var/lib/apt/lists
    ln -sf $(find $PWD/apt/sources.list.d -type f) /etc/apt/sources.list.d/
    ln -sf $(find $PWD/apt/trusted.gpg.d -type f) /etc/apt/trusted.gpg.d/
fi

# download the real andrewgdotcom-keyring package
apt-get update
apt-get install andrewgdotcom-keyring

# now cache packages to keep the tails additional software installer happy
apt-get --download-only install $(<live-additional-software.conf)

# finally delete the bootstrap signing key
rm apt/trusted.gpg.d/andrewg-codesign-temp.gpg

# reboot to make sure everything starts up in the right place
echo "Rebooting in 5s to activate new configuration..."
sleep 5

reboot
