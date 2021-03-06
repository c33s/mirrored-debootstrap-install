Creating a KVM Ubuntu VM using Debootstrap
------------------------------------------

This repository contains scripts to automatically create a KVM image
based on the parameters specified in `config.sh`.

The overall process is described [here](http://blog.ericwhite.ca/articles/2010/10/kvm-ubuntu-vm-using-debootstrap/).

Requirements:

 * Debian/Ubuntu starting system
 * $ sudo apt-get install debootstrap grub germinate reprepro kpartx uml-utilities qemu-kvm parprouted
 * sudo

Running these scripts
---------------------

To run these scripts first set some local variables in your
environment used to create and configure the guest.  The default
configuration comes from `config.bash`, but the key elements are set
in the environment using the `guest.sh` script.  This will also save
the configured setting in guests/<hostname>.params.  This parameter
file can then be used to lauch a shell using: 
   ./guest.sh --shell -f guests/<hostname>.params 

To see the `guest.sh` usage:

<pre>
$ ./guest.sh
Usage: ./guest.sh -v <HOSTNAME> -d <DOMAINNAME> -s <STATICIP> -m <NETMASK> -g <GATEWAY> -n <NAMESERVER>

   Start a /bin/bash shell with a configured environment.
     ./guest.sh --shell -v <HOSTNAME> -d <DOMAINNAME> -s <STATICIP> -m <NETMASK> -g <GATEWAY> -n <NAMESERVER>
</pre>

Next create a shell environment to run the scripts in.

<pre>
$ ./guest.sh --shell -v VM01
[INFO ] Using a root directory of .../ubuntu-bootstrap
[INFO ] Loading configuration from .../ubuntu-bootstrap/config.bash
Using Ubuntu
  Release      : maverick
  Architecture : amd64
  Mirror       : http://gb.archive.ubuntu.com/ubuntu

Using network configuration
  hostname  : VM01
  domain    : example.com
  fqdn      : VM01.example.com
  static-ip : 10.80.20.201
  netmask   : 255.255.255.0
  gateway   : 10.80.20.1
  nameserver: 10.80.20.10
</pre>

At this point make any modifications to `additional.packages` and run
through the scripts `01-...`, `02-...`, `03-...`,`04-...`, etc.

Care has been put into these scripts to check the output of each
command.  So that they should fail fast if something goes wrong.

<pre>
01-create-boostrap-mirror.bash
02-create-kvm-disk-image.bash
03-install-ubuntu.bash
04-configure-basics.bash
05-install-additional-packages.bash
06-install-grub.bash
07-final-touches.bash
</pre>

Booting the vm
==============

Booting with out the network card.  The root password should be set to `gotcha12`.

<pre>
kvm -drive file=ubuntu-maverick-amd64.img,index=0,media=disk -m 256m
</pre>

See: 'Wireless Bridge for Laptop Hosts' at end of this article for
the setup of a network taped interface [here](http://blog.ericwhite.ca/articles/2010/10/kvm-ubuntu-vm-using-debootstrap/).

<pre>
kvm -drive file=ubuntu-maverick-amd64.img,index=0,media=disk \
    -net tap,ifname=tap0,script=no,downscript=no -net nic \
    -m 256m
</pre>

Post Boot
=========

At this point the network should be available from within the VM.  If
that is working then the `apt` cache should be updated against the
mirror.  And the root password should be changed.

<pre>
As root

# aptitude update
# passwd
</pre>


Helping out
-----------
Ideas, suggestions, bug fixes are all welcome.


Working with Partial Installs
-----------------------------

The scripts are intended to be run one after another, but during
testing it is sometimes handy to rerun bits of the process to fine
tune the result.

Updating the Additional Packages List
===================================== 

If you find that part way through the installation process you would
like additional packages.  You can modify `additional.packages` or
`mirror.packages` and re-run `01-create-boostrap-mirror.bash` the new
packages will be downloaded and mirror updated.  This process should
only take a small amount of time as only the new packages will be
downloaded.

Re-running the script will also download new updates for previously
mirrored packages.

Issues
======
I. The kernel image is failing to install.

I had this issue in one VM and got around it by specifying an exact
kernel in additional.packages, rerunning step 01, and then step 05.

Utilities
=========
The following utility scripts are useful for dealing with the choot VM.

 * `10-mount-image.bash` -- Mounts the VM in the host
 * `11-umount-image.bash` -- Unmounts the VM in the host
 * `12-chroot.bash` -- Chroot into a mounted VM (Can be run standalone)
