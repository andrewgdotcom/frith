# How to export subkeys to Canary Mail on iOS

* Start Tails, remembering to unlock persistent storage *and* set an admin password
* Connect iPhone and allow access from laptop
* Open a terminal
* In one tab, incant:

```
sudo -i
apt-get install ifuse
ifuse /mnt --documents Mailroom.Canary-iOS
```

* In a second tab, start `frith` and export your subkeys
* Choose `/mnt` as the export location
* Now open Canary Mail settings and import PGP keys
* Choose "transferred by Finder" and select the exported file
* Now on the laptop, in the `sudo` tab, where `xxxxxx.gpg` is the name of the exported key file:

```
rm /mnt/xxxxxx.gpg
umount /mnt
```

* Profit!
