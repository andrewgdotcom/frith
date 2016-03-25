#!/bin/bash
set -e

GITHUB_ROOT=https://github.com/andrewgdotcom/frith/raw/master
PERSISTENT_VOL=/live/persistence/TailsData_unlocked

cd $PERSISTENT_VOL

# configure additional software persistence
# this is a custom persistence config to let us use non-standard APT repos
#
# NB this will overwrite any existing persistence configuration!

echo frith >> live-additional-software.conf
wget -qO persistence.conf $GITHUB_ROOT/skel/persistence.conf

for i in apt/conf/sources.list.d apt/conf/trusted.gpg.d apt/lists apt/cache; do
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

wget -qO apt/conf/trusted.gpg.d/andrewg-codesign.gpg $GITHUB_ROOT/skel/apt/conf/trusted.gpg.d/andrewg-codesign.gpg 
wget -qO apt/conf/sources.list.d/andrewg.list $GITHUB_ROOT/skel/apt/conf/sources.list.d/andrewg.list

# now activate the persistent APT configuration and install frith package
# so that we can use it straight away
#
# NB this also populates the APT cache for future use disconnected

ln -s $PERSISTENT_VOL/apt/conf/sources.list.d/andrewg.list /etc/apt/sources.list.d/
ln -s $PERSISTENT_VOL/apt/conf/trusted.gpg.d/andrewg-codesign.gpg /etc/apt/trusted.gpg.d/
apt-get update && apt-get install -y frith

