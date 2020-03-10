#!/bin/bash
set -e

# We do some things as a normal user, then some things as root

if [[ $(whoami) != root ]]; then
    # Perform network operations as ordinary user
    TMPDIR=$(mktemp -d)
    wget https://andrewg.com/andrewg-codesign.pub -O $TMPDIR/andrewg-codesign.asc
    # Now call ourselves recursively
    sudo /usr/bin/env TMPDIR=$TMPDIR /bin/bash $0
elif [[ ! $TMPDIR ]]; then
    echo "Please don't run this script as root (i.e. with sudo)"
    exit 1
fi

PERSISTENT_VOL=/live/persistence/TailsData_unlocked

if [[ "$1" ]]; then
  cd "$1"
else
  cd $PERSISTENT_VOL
fi

# configure additional software persistence
# this is a custom persistence config to let us use non-standard APT repos
#
# NB this will overwrite any existing persistence configuration!

echo frith >> live-additional-software.conf

cat <<EOF > persistence.conf
/home/amnesia/Persistent	source=Persistent
/home/amnesia/.gnupg	source=gnupg
/var/cache/apt/archives	source=apt/cache
/var/lib/apt/lists	source=apt/lists
/etc/apt/sources.list.d	source=apt/sources.list.d,link
EOF

# Before we continue, trash any stale APT config. Frith is a jealous god.
# Also, he screwed up in the past and wants to repent.

rm -rf apt

# ensure the peristent directories are properly created

for i in apt/sources.list.d apt/lists apt/cache; do
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

# Put our pubkey under sources.list.d and refer to it in the .list file
# This is safe because apt ignores dotfiles.
# Don't use trusted.gpg.d as it grants global trust, which is excessive
# https://wiki.debian.org/DebianRepository/UseThirdParty

cat <<EOF > apt/sources.list.d/andrewg.list
deb [signed-by=/etc/apt/sources.list.d/.andrewg-codesign.gpg] tor+http://andrewg.com/debian andrewg main
EOF

gpg --no-default-keyring --keyring=apt/sources.list.d/.andrewg-codesign.gpg --import $TMPDIR/andrewg-codesign.asc
# This might leave a backup file; clean it up
rm "apt/sources.list.d/.andrewg-codesign.gpg~" || echo -n

if [[ "$1" ]]; then
  # if we are installing on a target disk, don't proceed any further
  exit 0
fi

# Update and install now, to make sure the debfiles are cached
apt-get update && apt-get -y install frith

# reboot to make sure everything starts up in the right place

echo "Rebooting in 5s to activate new configuration..."
sleep 5

reboot
