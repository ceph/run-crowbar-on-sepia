======================
 Run Crowbar on Sepia
======================

Here are quick & ugly scripts to run Crowbar on Sepia.


Installation
============

Install necessary packages::

    sudo apt-get install libvirt-bin python-lxml

Add aliases to avoid typing so much::

    install -d -m0755 ~/.libvirt
    cat <<-'EOF'
	uri_aliases = [
	    'vercoi01=qemu+ssh://ubuntu@vercoi01.front.sepia.ceph.com/system?no_tty',
	    'vercoi02=qemu+ssh://ubuntu@vercoi02.front.sepia.ceph.com/system?no_tty',
	    'vercoi03=qemu+ssh://ubuntu@vercoi03.front.sepia.ceph.com/system?no_tty',
	    'vercoi04=qemu+ssh://ubuntu@vercoi04.front.sepia.ceph.com/system?no_tty',
	    'vercoi05=qemu+ssh://ubuntu@vercoi05.front.sepia.ceph.com/system?no_tty',
	    'vercoi06=qemu+ssh://ubuntu@vercoi06.front.sepia.ceph.com/system?no_tty',
	    'vercoi07=qemu+ssh://ubuntu@vercoi07.front.sepia.ceph.com/system?no_tty',
	    'vercoi08=qemu+ssh://ubuntu@vercoi08.front.sepia.ceph.com/system?no_tty',
	    ]
    EOF

Test your libvirt client::

    virsh -c vercoi08 hostname


Picking a server to use
=======================

There are several servers. You need to pick one. There is currently no
automation to help you pick.

Avoid ``vercoi01`` and ``vercoi02``, they will be running more
production-ish vms.

Avoid servers that are low on free RAM. Use ``virsh -c vercoiNN
nodememstats``.

You can spread a single Crowbar setup over multiple servers.


Usage
=====

Things you need:

- ``URI``: the libvirt server to talk to, looks like ``vercoiNN``
- ``NETWORK``: reserve an isolated network: https://docs.google.com/a/inktank.com/spreadsheet/ccc?key=0ArMxA48Whwo_dHVNQUNLeDMyTjZaSjNTTjB6d2s4VkE#gid=0
  looks like ``isolatedN``
- ``ISO``: choose what ISO to use (``openstack-fred.iso`` was latest
  upstream when this was written)
- ``NAME``: pick a unique name for your run -- it should include your
  username in it, for example ``jdoe-bug1234``


To create the admin node::

    ./create-admin URI NETWORK ISO NAME

Now connect to the console via VNC and finish the
installation. ``virt-manager`` is a nice tool for Linux users. Once
again, replace ``NAME`` with what you chose above, and run::

    cd /tftpboot/ubuntu_dvd/extra
    sudo ./install NAME.crow.sepia.ceph.com
    sudo screen -r

TODO VNC guide for non-linux

To use the Crowbar web UI, run on the console::

    sudo dhclient eth1
    ip a show dev eth1

And, using the IP address shown, open browser to http://IP:3000/

-----

Once the server is running, add nodes by running::

    ./create-node URI NETWORK NAME 1
    ./create-node URI NETWORK NAME 2
    # repeat with increasing numbers, if you need more

-----

And finally, once you are done testing, remove your vms::

    ./destroy URI NAME

``destroy`` only acts on one server. If you spread your Crowbar setup
over multiple servers, run it against all the servers you had virtual
machines on.
