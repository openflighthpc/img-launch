# Image Launcher

## Overview

Creates a libvirt VM from a raw image, customises with cloud-init and applies profile with scripts.

## Install

- Ensure dependencies are installed
    - `libvirt`
    - `virt-install`
- Clone the repository to your libvirt VM root directory (e.g. `/opt/vm`)

## How To

- Download source image to `images/`
- Set variables in `config.sh`
- Create/modify profile script in `scripts`
- Build VM
  ```shell
  bash bin/build.sh
  ```

## Conventions

- `bin/` - Stand-alone scripts for running various stages of the build process
  - `apply-profile.sh` - Runs both the base & profile-specific scripts on the appliance
  - `build.sh` - Runs the scripts for generating cloud-init ISO, creating VM and applying the profile
  - `create-vm.sh` - Creates a libvirt VM from the raw image
  - `delete_failed.sh` - Undefines and deletes VM resources defined in `config.sh`
  - `gen-cloud-init.sh` - Creates an ISO file with cloud-init info for a node
- `build/` - Contains build-specific info within directories named after the VM being created
- `images/` - The location to store raw images
- `scripts/` - Profile script storage
  - `base.sh` - A generic script that will be run before applying the specific profile script

## Future Things

- Further network configuration
- More profiles
- AWS/Azure support
- OpenStack support

