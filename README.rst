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
    cat >~/.libvirt/libvirt.conf <<-'EOF'
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
installation. ``virt-manager`` is a nice tool for Linux users.

Log in on the console as user ``crowbar`` password ``crowbar``, and
replacing ``NAME`` with what you chose above run::

    cd /tftpboot/ubuntu_dvd/extra
    sudo ./install NAME.crow.sepia.ceph.com
    sudo screen -r

TODO VNC guide for non-linux

Run the following and eth1 will be automatically available after each
reboot::

    sudo tee /etc/dhcp/dhclient-enter-hooks.d/inktank-kludge-resolvconf <<'EOF'
    # prevent dhclient from updating /etc/resolv.conf
    #
    # Crowbar wants to use Chef templates to manage this file
    # (and control DNS resolution for the node names); without
    # this, the two will fight about the contents
    make_resolv_conf() { :; }
    EOF

    sudo tee /etc/init/inktank-dhcp.conf <<-'EOF'
	description "Bring up 'front' network on eth1."
	start on startup
	script
	  exec /sbin/dhclient -d eth1
	end script
    EOF

To get an IP address without a reboot, run::

    sudo start inktank-dhcp

Once you have the DHCP lease, you can see the Crowbar admin interface
at http://crow-NAME-admin.front.sepia.ceph.com:3000/ (once again,
replace ``NAME`` with what you chose above).

-----

Once the server is running, add nodes by running::

    ./create-node URI NETWORK NAME 1
    ./create-node URI NETWORK NAME 2
    # repeat with increasing numbers, if you need more

-----

You can use web interfaces provided by Crowbar nodes with a SOCKS5
tunnel to the Crowbar server. First, establish the tunnel::

    ./socks NAME

You can background ``socks``, or just leave it running in a
terminal. Remember to stop it when you're done, by bringing it to
foreground and pressing ``control-C``.

And then run a specially configured browser that uses that tunnel::

    ./remotely-firefox

The browser is able to see the Crowbar-managed DNS names, so you don't
need to use IP addresses.

You can also pass URLs to ``remotely-firefox`` on the command line.
for example (replace X's)::

    ./remotely-firefox http://d52-54-00-XX-XX-XX.crow.sepia.ceph.com/

By default, these commands use port 2000 to communicate. If you need
to browse multiple Crowbar clusters at once, you'll need to manage
ports manually. Use ``-p 2001`` and so on; see the help messages of
the commands for more.

-----

And finally, once you are done testing, remove your vms::

    ./destroy URI NAME

``destroy`` only acts on one server. If you spread your Crowbar setup
over multiple servers, run it against all the servers you had virtual
machines on.
