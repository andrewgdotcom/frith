#!/bin/bash
set -e

TMPDIR=$(mktemp -d)
PERSISTENT_VOL=/live/persistence/TailsData_unlocked
SKELETON_DIR=/var/cache/frith

if [[ "$1" == "skel" ]]; then
  cd $SKELETON_DIR
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

# Put our pubkey in sources.list.d and refer to it in the .list file
# This is safe because `apt-get update` ignores unknown file extensions
# Don't use trusted.gpg.d as it grants global trust, which is excessive
# https://wiki.debian.org/DebianRepository/UseThirdParty

cat <<EOF > apt/sources.list.d/andrewg.list
deb [signed-by=/etc/apt/sources.list.d/andrewg-codesign.gpg] tor+http://andrewg.com/debian andrewg main
EOF

cat <<EOF > $TMPDIR/andrewg-codesign.asc
-----BEGIN PGP PUBLIC KEY BLOCK-----

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
=tXyi
-----END PGP PUBLIC KEY BLOCK-----
EOF
gpg --no-default-keyring --keyring=apt/sources.list.d/andrewg-codesign.gpg --import $TMPDIR/andrewg-codesign.asc

if [[ "$1" == "skel" ]]; then
  # don't reboot
  exit 0
fi

# reboot to make sure everything starts up in the right place

echo "Rebooting in 5s to activate new configuration..."
sleep 5

reboot
