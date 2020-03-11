Frith
=====

Frith is an EXPERIMENTAL offline utility to simplify PGP public key creation and management.

Frith is designed so that your master PGP key is never stored on your everyday computer(s), but kept on a (mostly) offline bootable flash drive that only needs to be brought online to certify other users' keys. To this end, frith strongly recommends the use of Tails, a bootable flash drive OS with an (optional) encrypted storage partition. While the anonymisation features of Tails are not strictly required, the Tor layer acts as a firewall for those occasions when frith must be brought online.

* [Frith project homepage](https://andrewg.com/frith.html)
* [Frith github repository](https://github.com/andrewgdotcom/frith)

Requirements
------------

* A computer that can boot from USB and has two usable USB ports
* A fresh downloaded image of [Tails](https://tails.boum.org/install/)
* Two 8GB flash drives, such as [Kingston Data Traveler SE9](https://www.amazon.co.uk/Kingston-Technology-DataTraveler-Flash-Casing/dp/B006YBAR0C/ref=pd_sim_sbs_147_1?ie=UTF8&refRID=08PZ6GR4V00M10DAT14P&dpID=31P0IK%2BzEJL&dpSrc=sims&preST=_AC_UL160_SR160%2C160_) (buy in bulk, they're cheap as chips)
* At least one of:
    * A [PGP Smartcard v2](https://en.cryptoshop.com/products/smartcards/open-pgp-smartcard-v2-id-000.html) (optionally with an external card reader if your computer(s) lack a built-in reader)
    * A [PGP compatible Yubikey](https://yubico.com/)
    * A third removable drive (for transferring subkeys to devices that don't support smartcards)

Beware that some bulkier USB drives can obstruct adjacent USB ports, preventing a second drive from being connected. It is recommended to use slimline models (such as the one mentioned above) to minimize frustration.

Alternatives to PGP Smartcards and Yubikeys exist (see the [Debian smartcard support page](https://wiki.debian.org/Smartcards) for a partial list). It is possible to use these with frith, but they may not be as thoroughly tested. If you want to use such a device, check first that it supports 4096-bit RSA keys. Many only support 2048-bit — these may work with frith, but not with its default settings.

Note that frith will never generate a key on the card itself, but will always generate on the computer and then copy to the card. This is so that you can keep a backup of your key material, but it also protects against [poorly-implemented hardware random number generators](http://ieeexplore.ieee.org/document/6994021/?reload=true).

Some devices (smartphones, tablets...) may not be compatible with PGP smartcards — in such cases you will need to save your subkeys to a third removable drive for transfer to the device by other means. This is not as secure as using a smartcard, and should only be done when absolutely necessary.

Getting started
---------------

### Installing frith

WARNING: This will overwrite any persistent configuration you have already set up, so should only be done on a fresh Tails install. We strongly recommended that a Tails drive with frith installed is NOT used for any other purpose, as frith is not supported by the Tails team and may have unexpected side effects.

1. Install Tails on the first 8GB flash drive by [following their instructions](https://tails.boum.org/install/)
2. Boot into the first drive
3. Configure an encrypted persistent volume as described in the Tails instructions
4. Reboot
5. When the greeter appears, enter the passphrase for the persistent drive, then click the "+" for more options
6. Set a temporary administration password and continue to boot into Tails
7. Open a terminal and cut and paste the following into it.
```
wget -q https://github.com/andrewgdotcom/frith/raw/master/frith-install.sh
sha256sum frith-install.sh
```
This should produce the following output:
```
9cec720cebc8b0e0dbd5616d7c31910c320cbe8d9dbb0bb94def9339b1ea7a3f  frith-install.sh
```
8. Only if the above checks out, run the installer. You will be prompted for the temporary administration password ("sudo password"):
```
bash frith-install.sh
```

9. Tails will automatically reboot. Continue to "First time running frith" below

### First time running frith

1. When prompted, select "Yes" for persistence and enter the passphrase
2. Open Applications -> Favorites -> Terminal and run 'frith'
3. Follow the getting started procedure. This will prompt you for your personal details, create a new set of keys and perform a backup to the second Tails drive
4. When prompted, plug in the smartcard and/or the subkey flash drive
5. Frith will then publish your new public key
6. You're done!

Remember to store the second Tails disk in a secure remote location.

Usage
-----

Once you have your smartcard populated with your subkeys, you can use it on your everyday computer. You will need to download the matching public key first, as the smartcard only contains your private keys.

On your everyday computer, insert the smartcard and run the following in a terminal:

```
gpg --card-edit fetch
```

You can then use gpg normally.

If you saved your subkeys to a flash disk, you can install them on your everyday computer and continue from there. This does not protect your subkeys from theft, but your primary key is safe, and you can revoke and replace the subkeys more easily than replacing your entire key. With GnuPG, this is done using:

```
gpg --import FILENAME
```

Where FILENAME is the name of the file that you saved. If you want to use iPGMail on iOS, you should connect your phone/tablet to iTunes to transfer the file. Do not use the Dropbox option, as this is insecure! (note: iPGMail does not yet support laptop subkeys without the primary, but with luck this will change soon)

Frith is then only required when you want to do one of the following:

* Create, revoke, or change the expiry date of a primary key or subkey
* Add or revoke an ID
* Certify someone else's identity

In such cases you need to boot from one of the Tails drives, perform the operation, and republish any changed keys. You only need to make a fresh backup if you have created a new primary key or subkey.

Note that in order to use frith, you must enable persistence each time you boot Tails. This is a security feature! (You only need to set the temporary administration password when you are installing frith for the first time)

### Recommended client software

* [Enigmail for Thunderbird](https://www.enigmail.net/)
* [monkeysphere for openssh](http://web.monkeysphere.info/)
* [pam_ssh_agent_auth for sudo](http://pamsshagentauth.sourceforge.net/)

To use smartcard auth with putty, you must download [<em>GnuPG modern for Windows</em> from the official GnuPG site](https://www.gnupg.org/download/). No other version currently has putty support.

### Recommended hardware

Smartcards:

* [OpenPGP Smartcard v2.1](https://en.cryptoshop.com/products/smartcards/open-pgp-smartcard-v2.html)
	* [with SIM breakout](https://en.cryptoshop.com/products/smartcards/open-pgp-smartcard-v2-id-000.html)

Smartcard readers:

* [ACS ACR38T](https://en.cryptoshop.com/products/smartcardreader/acs-acr-38t.html) — SIM format, portable ([drivers](http://www.acs.com.hk/en/driver/4/acr38t-smart-card-reader/))
* [Athena ASEDrive IIIe V3CR](https://en.cryptoshop.com/products/smartcardreader/athena-asedrive-iiie-v3-usb-reader.html) — full-size, external (not recommended for SIM breakout cards as they can jam)
* [CSL - USB smart card reader](https://www.amazon.co.uk/CSL-bus-powered-Capable-Windows-10-compatible/dp/B01GCTVAGA) - full size, external
* [Broadcom BCM5880](https://www.broadcom.com/products/enterprise-and-network-processors/security/bcm5880) — full-size, internal (used in DELL laptops, amongst others)

Flash drives:

* [Kingston Data Traveler SE9](https://www.amazon.co.uk/Kingston-Technology-DataTraveler-Flash-Casing/dp/B006YBAR0C/ref=pd_sim_sbs_147_1?ie=UTF8&refRID=08PZ6GR4V00M10DAT14P&dpID=31P0IK%2BzEJL&dpSrc=sims&preST=_AC_UL160_SR160%2C160_)
