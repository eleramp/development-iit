#!/bin/bash
set -eu -o pipefail

if [ -x "$(which setup_tools.sh)" ] ; then
    # Setup the parent image
    echo "==> Configuring the parent image"
    source $(which setup_tools.sh)
    echo "==> Parent tools image configured"
    
    # Setup git for the runtime user
    su -c "git config --global remote-hg.ignore-name '~|pre|pendulum'" $USERNAME
fi

# Setup the custom bashrc
echo "==> Including additional bashrc configurations"
cp /usr/etc/skel/bashrc-dev /home/$USERNAME/.bashrc-dev
chown ${USERNAME}:${USERNAME} /home/$USERNAME/.bashrc-dev
echo "source /home/$USERNAME/.bashrc-dev" >> /home/${USERNAME}/.bashrc
echo "source /home/$USERNAME/.bashrc-dev" >> /root/.bashrc

# Change the permission of all persistent resources mounted inside $HOME.
# If you don't want to get a chowned resource, mount it somewhere else.
if [ -n "$(mount | tr -s " " | cut -d " " -f 3 | grep /home/${USERNAME})" ] ; then
    echo "Fixing mounted volumes permissions"
    declare -a RESOURCES_MOUNTED_IN_HOME
    RESOURCES_MOUNTED_IN_HOME=($(mount | tr -s " " | cut -d " " -f 3 | grep /home/${USERNAME}))
    for resource in ${RESOURCES_MOUNTED_IN_HOME[@]} ; do
        echo " -> Changing ownership of $resource"
        chown -R ${USERNAME}:${USERNAME} $resource
    done
fi

# Change the permissions of .local and .config
[ -d /home/${USERNAME}/.local ] && chown -R ${USERNAME}:${USERNAME} /home/${USERNAME}/.local
[ -d /home/${USERNAME}/.config ] && chown -R ${USERNAME}:${USERNAME} /home/${USERNAME}/.config

set -eu -o pipefail


