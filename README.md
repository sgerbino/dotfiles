# Dotfiles

## Arch Linux

### Secure boot
[Arch Linux: Secure boot](https://wiki.archlinux.org/title/Unified_Extensible_Firmware_Interface/Secure_Boot)

Ensure you have the necessary package, `pacman -S sbctl`.

Before proceeding, ensure that your firmware secure boot is in setup mode.
You can verify by calling `sbctl status`.

1. Create your keys.
```console
sbctl create-keys
```

2. Enroll your keys, along with Microsoft keys, to the UEFI.
```console
sbctl enroll-keys -m
```

3. Check what images need to be signed.
```console
sbctl verify
```

Example output:
```console
Verifying file database and EFI images in /boot...
✓ /boot/EFI/BOOT/BOOTX64.EFI is signed
✓ /boot/EFI/Linux/arch-linux.efi is signed
✓ /boot/EFI/systemd/systemd-bootx64.efi is signed
✓ /boot/vmlinuz-linux-lts is signed
✓ /usr/lib/systemd/boot/efi/systemd-bootx64.efi.signed is signed
✓ /boot/EFI/Linux/arch-linux-fallback.efi is signed
✓ /boot/EFI/Linux/arch-linux-lts-fallback.efi is signed
✓ /boot/EFI/Linux/arch-linux-lts.efi is signed
✓ /boot/vmlinuz-linux is signed
```

4. Sign each image.
```console
sbctl sign -s /boot/vmlinuz-linux
```
_Do this for each of the required images from the previous step._

5. Sign the bootloader.
```console
sbctl sign -s -o /usr/lib/systemd/boot/efi/systemd-bootx64.efi.signed /usr/lib/systemd/boot/efi/systemd-bootx64.efi
```

### TPM2
[Arch Linux: TPM](https://wiki.archlinux.org/title/Trusted_Platform_Module)

Ensure you have the necessary package, `pacman -S tpm2-tss`.

1. Create `/etc/crypttab.initramfs`, example:

```conf
root UUID={UUID_HERE} luks,tries=3,tpm2-device=auto
```
_Replace {UUID_HERE} with your encrypted drive UUID._

2. Update `HOOKS` in `/etc/mkinitcpio.conf`, example:

```conf
HOOKS=(base systemd autodetect microcode modconf kms keyboard sd-vconsole sd-encrypt block filesystems fsck)
```

3. Set up systemd cryptenroll, example:

```console
systemd-cryptenroll --wipe-slot=tpm2 /dev/disk/by-uuid/{UUID_HERE}
systemd-cryptenroll --tpm2-device=auto --tpm2-pcrs=0+7 /dev/disk/by-uuid/{UUID_HERE}
```
_Replace {UUID_HERE} with your encrypted drive UUID._

4. Rebuild your initial RAM disk, example:

For one kernel:
```
mkinitcpio -p linux
```

Or for all:
```
mkinitpcio -P
````
