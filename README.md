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
- Copy `config.sh.example` to `config.sh` and set variables
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
- `scripts/` - Profile script storage (note: vars in `config.sh` will be made available to these scripts)
  - `base.sh` - A generic script that will be run before applying the specific profile script

## Future Things

- Further network configuration
- More profiles
- AWS/Azure support
- OpenStack support

## Notes

### Gateway

The gateway hosts a client script that can be curled in order to configure the default route of the client. This does a bit of magic to identify what subnet of the gateway's to use for the client depending on its network setup. **The assumptions only work should the gateway use identical last 2 octets in its IP address**. For example, the gateway's SITE & PRI IPs both end `254.1`.
