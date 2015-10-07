Frith
=====

Frith is an EXPERIMENTAL offline utility to simplify PGP public key creation and management. It is an attempt to implement the best possible practice as cribbed from various resources:

*    OpenPGP Best Practices (riseup.net)
*    Creating the perfect GPG keypair (Alex Cabal)
*    Generating More Secure GPG Keys: A Step-by-Step Guide (Mike English)

Frith is designed so that your master PGP key is never stored on your everyday computer(s), but kept on a (mostly) offline bootable flash drive that only needs to be brought online to certify other users' keys. To this end, frith strongly recommends the use of Tails, a bootable flash drive OS with an (optional) encrypted storage partition. While the anonymisation features of Tails are not strictly required, the Tor layer acts as a firewall for those occasions when frith must be brought online.

Requirements
------------

* A computer that can boot from USB and has two usable USB ports
* A fresh downloaded image of Tails
* Two 8GB flash drives, such as Kingston Data Traveler SE9 (buy in bulk, they're cheap as chips)
* At least one of:
    * A PGP Smartcard v2 (optionally with a card reader if your computer(s) lack a built-in reader)
    * A third removable drive (for transferring subkeys to devices that don't support smartcards)

Beware that some bulkier USB drives can obstruct adjacent USB ports, preventing a second drive from being connected. It is recommended to use slimline models (such as the one mentioned above) to minimize frustration.

Alternatives to PGP Smartcards exist, such as the YubiKey NEO (see the Debian smartcard support page for a list). It is possible to use these with frith, but they may not be as thoroughly tested. If you want to use such a device, check first that it supports 4096-bit RSA keys. Many only support 2048-bit — these may work with frith, but not with its default settings. YMMV, caveat emptor, etc.

Some devices (smartphones, tablets...) may not be compatible with PGP smartcards (but check out the YubiKey NEO above) — in such cases you will need to save your subkeys to a third removable drive for transfer to the device by other means. This is not as secure as using a smartcard, and should only be done when absolutely necessary.

Frith does not handle ECC keys (yet!) — support for these is limited in the wild so far. This will probably change once software support becomes more widespread.

Getting started
---------------

If you (or a colleague) already have a copy of frith, you can use it to make a fresh one. Use "Applications" > "Tails" > "Tails Installer" > "Clone and install" to make a new install of Tails on the first flash drive, then run frith and go to "Backup and Restore" > "Install frith software on a Tails disk". It will prompt you for a disk encryption passphrase - use a very strong one. Boot into the new disk and jump straight to step 9 below.

To start from scratch:

1. Install Tails on the first 8GB flash drive by following their instructions
1. Boot into the first drive
1. Configure a persistent volume as described here. Be sure to use a very strong encryption passphrase. Enable "GnuPG", "APT lists" and "APT packages"
1. Reboot
1. When prompted, select "Yes" for persistence and enter the passphrase. Also select "Yes" for "more options" and continue
1. Set a temporary administration password and continue
1. Open a terminal and cut and paste the following into it. You will be prompted for the temporary administration password

```
sudo bash -c "wget -qO - https://andrewg.com/andrewg-codesign.pub | apt-key add - ; cd /live/persistence/TailsData_unlocked; echo frith >> live-additional-software.conf; echo '/etc/apt source=apt/conf' >> persistence.conf; chown tails-persistence-setup:tails-persistence-setup live-additional-software.conf persistence.conf; chmod og= live-additional-software.conf persistence.conf; echo 'deb tor+http://andrewg.com/debian andrewg main' > /etc/apt/sources.list.d/andrewg.list; cp -a /etc/apt apt/conf; apt-get update && apt-get install -y frith"
```

1. Reboot
1. When prompted, select "Yes" for persistence and enter the passphrase
1. Use "Applications" > "Tails" > "Tails Installer" > "Clone and install" to install Tails on the second 8GB flash drive. Leave it plugged in
1. Open a terminal and run 'frith'
1. Follow the getting started procedure. This will prompt you for your personal details, create a new set of keys and perform a backup to the second Tails drive
1. When prompted, plug in the smartcard and/or the subkey flash drive
1. Frith will then publish your new public key (unless you started it with the --nopublish option)
1. You're done!

Remember to store the second Tails disk in a secure remote location.

Usage
-----

Once you have your smartcard populated with your subkeys, you can use it on your everyday computer. You will need to download the matching public key first, as the smartcard only contains your private keys. With GnuPG, this is done by incanting the following the first time the smartcard is inserted:

```
gpg --edit-card fetch
```

You can then use gpg normally.

If you saved your subkeys to a flash disk, you can install them on your everyday computer and continue from there (remembering that this does not protect your subkeys from theft, but at least your primary key is safe...). With GnuPG, this is done using:

```
gpg --import FILENAME
```

Where FILENAME is the name of the file that you saved. If you want to use iPGMail on iOS, you should upload this file to Dropbox so that the app can find it. This is not ideal, so deleting the file immediately afterwards is strongly advised.

Frith is then only required when you want to do one of the following:

* Create, revoke, or change the expiry date of a primary key or subkey
* Add or revoke an email address or photo ID (anything requiring a fresh self-signature)
* Certify someone else's identity

In such cases you need to boot from one of the Tails drives, perform the operation, and republish any changed keys. You only need to make a fresh backup if you have created a new primary key or subkey.

Note that in order to use frith, you must enable persistence each time you boot Tails. This is a security feature! (You only need to set the temporary administration password if you are installing frith for the first time)

Footnote
--------

This project was originally called monkeybox (alluding to both monkeysphere and busybox), however the name was taken. It was renamed frith on 2015-09-30. 
