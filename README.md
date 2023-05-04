---


![Skylined banner{caption= bruh}](https://github.com/nekomekoraiyuu/skylined/raw/assets/skylined_header.gif "Skylined banner")
<p align="center">
<em>
A no joke, user-friendly and "high quality" nsp updater script for skyline emulator! ✨
</em>
</p>

![skylined branch](https://img.shields.io/badge/branch-dev-inactive) ![programming lang](https://img.shields.io/badge/made%20in-bash-important) ![license](https://img.shields.io/badge/license-GPLV3-critical)
![skylined version](https://img.shields.io/badge/version-1-green) ![funding moment](https://img.shields.io/badge/funding-markus%20tech-9cf)
---

# Table of contents:

---

- [Introduction / what's dis?](#intro)
- [Installation](#install)
- [Documentation / Script](#docs)
- [Limitations](#limits)
- [Credits](#credit)

<a id="intro" />

# what's dis?:
---

Skylined is a no joke "high quality" nsp 
updater script for Termux and WSL/Linux (W.I.P) which is made in pure bash;

The main basis of the script is to be as much as user-friendly as possible.

Also consider starring ✨ the repository to support the project--

### Why the script was made:

Well *ahem* what inspired me to make this script was the Github-Cli installer it had
a CLI-GUI selector and it looked very kewl to me so i wanted to try out making something similar in bash and guess what?

The result is this script!

`<Please note that this project is temporary and was only made to aid skyline until it adds update and dlc support.>`

<a id="install" />

# Installation:

---

## Termux:

To install in termux just copy paste this command and the installation script will do everything for you:

```bash
bash <(curl -s https://raw.githubusercontent.com/nekomekoraiyuu/skylined/dev/scripts/skylined_install.sh)
```

## WSL/Linux:

There are many flavors of Linux Distributions are available but here are the installation commands for the major distros.

### Debian and Ubuntu based distros:

Before you install the script make sure you have `curl` installed.

To check whether `curl` is installed or not you can type out this command:

```bash
which curl
```

If the output is blank then curl is not installed. Else the `curl` binary is installed.

You can install curl using this command:

```bash
sudo apt install curl -y
```

This will install curl binary for you;
(You can skip this step btw if you have it installed.)

If you already have `curl` installed or have it installed you can now finally run this command to install `skylined`:

```bash
sudo bash -c "bash <(curl -s https://raw.githubusercontent.com/nekomekoraiyuu/skylined/main/scripts/skylined_install.sh)"
```

No need to worry about anything the script will do everything automatically for you
just be patient :3

### Other distros (For intermediate users):

Well if your distro is unsupported or not in this list you can try installing it a bit manually.

To install this script you must have these dependencies installed:

> `git`
> `curl`
> `gcc`
> `binutils`
> `coreutils` (Please note that only `trap` is required)

If you have these all installed you can install `skylined` by typing out this command:

```bash
sudo bash -c "bash <(curl -s https://raw.githubusercontent.com/nekomekoraiyuu/skylined/main/scripts/skylined_install.sh) --skip-distro --skip-binaries"
```
<a id="docs" />

# Documentation:
---

### To get available arguments in the install script you can do:
```bash
$ <Install command here> --list-args
```

---

#### Currently the script only supports these rom formats below (ticked means supported):
- [x] `nsp`
- [ ] `xci`
- [ ] `nro`

#### List of supported arguments for the install script:

`This section is under W.I.P`

<a id="limits" />

# Limitations:

---

### As of now the current limitations are:

- Cannot update very large games like more than ~7-10 Gigabytes approx (It depends on the rom; Probably hactool issue)

`You can report any bugs in the issues section`

<a id="credit" />

# Credits:

---

- [Skyline](https://github.com/skyline-emu/skyline)
- [Bylaws](https://github.com/bylaws) (For reference); Also Willfaust (Initial reference)
- [Hactool](https://github.com/SciresM/hactool)
- [Hacpack](https://github.com/The-4n/hacPack)
