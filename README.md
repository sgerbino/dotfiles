# Dotfiles

This project makes use of git submodules. It is recommended to clone it recursively.
Before runnning `setup.sh` ensure that you have `stow` installed on your system. Running `setup.sh` will create symbolic links from the repository to the correct configuration locations.

## Git

Using the configuration provided by this repository is accomplished using `[include]` in `~/.gitconfig`.
When using the `smartcard reload` utility, your signing key is updated with `git`, by using the `[include]` strategy it does not modify any version controlled files.

Add the following to your `~/.gitconfig`.
```
[include]
	path = ~/.config/git/gitconfig
```

## Yubikey

After going through the setup process, or using a Yubikey to a freshly setup machine, there are several steps to take in order to utilize its features.
This particular set of instructions assume you use OpenPGP and SSH keys stored on your Yubikey, as well as use OTP for 2FA.

### SSH

In order for SSH to recognize your SSH keys, add it with the following command.
```console
ssh-add -K
```

To retrieve your public SSH key in order to add it to another machine or service like GitHub, use this command.
```console
ssh-add -L
```

### GPG

Yubikey GPG will install a private key stub that lets GPG know to ask the Yubikey when trying to sign for a particular key pair.

If you already have the associated public key in your keyring, execute this command to have the Yubikey install the private stub.
```console
gpg --card-status
```

A far easier strategy is to save the URL pointing to the public key on the smartcard itself. You can setup by performing the following action.
```console
gpg --edit-card
```

At the prompt, execute the `fetch` command. This will grab the public key from the URL and install the private key stub in one step.
```
Reader ...........: 0000:0000:X:0
Application ID ...: ABCDEF
Application type .: OpenPGP
Version ..........: 3.4
Manufacturer .....: Yubico
Serial number ....: 
Name of cardholder: [not set]
Language prefs ...: [not set]
Salutation .......: 
URL of public key : https://github.com/{USERNAME}.gpg
Login data .......: [not set]
Signature PIN ....: not forced
Key attributes ...: rsa4096 rsa4096 rsa4096
Max. PIN lengths .: 127 127 127
PIN retry counter : 3 0 3
Signature counter : 856
KDF setting ......: off
UIF setting ......: Sign=off Decrypt=off Auth=off
Signature key ....: 0123 4567 89AB CDEF 0123  4567 89AB CDEF 0123 4567
      created ....: 1970-01-01 00:00:00
Encryption key....: 0123 4567 89AB CDEF 0123  4567 89AB CDEF 0123 4567
      created ....: 1970-01-01 00:00:00
Authentication key: 0123 4567 89AB CDEF 0123  4567 89AB CDEF 0123 4567
      created ....: 1970-01-01 00:00:00
General key info..: 
pub  rsa4096/0123456789ABCDEF 1970-01-01 {NAME} <{EMAIL}>
sec>  rsa4096/0123456789ABCDEF  created: 1970-01-01  expires: never     
                                card-no: ABCDEF
ssb>  rsa4096/0123456789ABCDEF  created: 1970-01-01  expires: never     
                                card-no: ABCDEF
ssb>  rsa4096/0123456789ABCDEF  created: 1970-01-01  expires: never     
                                card-no: ABCDEF

gpg/card> fetch
```

### Swapping Yubikeys

When swapping smart cards a utility function is defined in `zsh`. It will allow the `gpg-agent` to recognize the new smartcard as well as inform `git` of the new OpenPGP key to sign with.

After switching your Yubikey use the following command.
```console
smartcard reload
```

## LLMs
[Dockerized Ollama](https://ollama.com/blog/ollama-is-now-available-as-an-official-docker-image)

This configuration makes use of AI to enhance tooling. It is integrated in both `neovim` and `sc`. Both applications expect you to have `ollama` listening on its default port. If you have an NVIDIA GPU, ensure that you have the `nvidia-container-toolkit` available for GPU acceleration inside containers.

Use the following command to pull down `ollama`.
```console
docker run -d --gpus=all -v ollama:/root/.ollama -p 11434:11434 --name ollama ollama/ollama
```

Update the container to restart unless stopped so the service is always available.
```console
docker update --restart=unless-stopped ollama
```

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
```
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

```
root UUID={UUID_HERE} luks,tries=3,tpm2-device=auto
```
_Replace {UUID_HERE} with your encrypted drive UUID._

2. Update `HOOKS` in `/etc/mkinitcpio.conf`, example:

```
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
