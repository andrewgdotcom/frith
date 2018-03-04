#!/bin/bash
set -e

TMPDIR=$(mktemp -d)
chown amnesia $TMPDIR

GITHUB_ROOT=https://github.com/andrewgdotcom/frith/raw/master
PERSISTENT_VOL=/live/persistence/TailsData_unlocked

cd $PERSISTENT_VOL

# configure additional software persistence
# this is a custom persistence config to let us use non-standard APT repos
#
# NB this will overwrite any existing persistence configuration!

echo frith >> live-additional-software.conf

# Drop permissions when downloading and save in a temp dir, then copy to proper location
sudo -u amnesia wget -qO $TMPDIR/persistence.conf $GITHUB_ROOT/skel/persistence.conf
cp $TMPDIR/persistence.conf .

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

# download the APT repo config directly from github

# Put pubkey in sources.list.d and refer to it in the .list file
# This is safe because `apt-get update` ignores unknown file extensions
# Don't use trusted.gpg.d as it grants global trust, which is excessive
# https://wiki.debian.org/DebianRepository/UseThirdParty
sudo -u amnesia wget -qO $TMPDIR/andrewg-codesign.gpg $GITHUB_ROOT/skel/apt/sources.list.d/andrewg-codesign.gpg
sudo -u amnesia wget -qO $TMPDIR/andrewg.list $GITHUB_ROOT/skel/apt/sources.list.d/andrewg.list
cp $TMPDIR/andrewg.list $TMPDIR/andrewg-codesign.gpg apt/sources.list.d/

# reboot to make sure everything starts up in the right place

echo "Rebooting in 5s to activate new configuration..."
sleep 5

reboot

