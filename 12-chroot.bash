#!/bin/bash
#
# Chroot into a previously created installation.
#
# Note: This script uses 'sudo'.
#
if [ -z UB_CONFIGURED ]; then
  lerror "Please execute 'guest.bash' to configure the environment first."
  false || die "UBE000"
fi

# Initialise some helpers
. ${UB_HOME}/functions.bash

(cd ${U_RELEASE}-${U_ARCH}-bootstrap
    linfo "Working in: ${U_RELEASE}-${U_ARCH}-bootstrap"

    # Unmount first in case this script is being run standalone.
    ${UB_HOME}/11-umount-image.bash || die
    ${UB_HOME}/10-mount-image.bash || die

    linfo "Switching into the: ${VM_ROOT}"
    sudo chroot ${VM_ROOT} /bin/bash

    ${UB_HOME}/11-umount-image.bash || die
)