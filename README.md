# Image Launcher

## Overview

Creates a libvirt VM from a raw image, customises with cloud-init and applies profile with scripts.

## Install

- Ensure dependencies are installed
    - `libvirt`
    - `virt-install`
- Clone the repository

## How To

- Download source image to `images/`
- Set variables in `config.sh`
- Create/modify profile script in `scripts`
- Build VM
  ```shell
  bash bin/build.sh
  ```

## Future Things

- Further network configuration
- More profiles
- AWS/Azure support
- OpenStack support

