# AutoCIFS

AutoCIFS is a client-side autofs-free CIFS Share Automount-Script, initially designed for Debian or derivates it now also runs smoothly on systems that use SysVinit, Upstart or Systemd init-systems like Ubuntu, OpenSUSE or RHEL/CentOS.

##### Status
[![Build Status](https://travis-ci.org/Barzahlen/autocifs.svg)](https://travis-ci.org/Barzahlen/autocifs)

## Available versions

If you want the latest stable version of AutoCIFS you can easily stick with the master branch. If you want a specific version, checkout the respective tagged commit.
The latest stuff is always available on the Development branch.

## Installation and Usage

The locations of the files are given through the folders in this Repository, so for example the autocifs.sh should reside in /usr/local/bin folder in your CIFS-Client.

1. Place a copy of the autocifs.sh (actual script) in the desired folder
2. Place a copy of the autocifs init/upstart/systemd file in the desired folder (see your init-systems folder)
  - Make both executable with `chmod +x /<path to the files>`
3. Place the /etc/default/autocifs file in the same path on your machine
  - Modify the file by setting the correct `CIFSSERVER` and `MOUNTS` vars and optionally `CIFSVERS`, `MOUNTOPT` and `INTERVAL` and set the correct location of the autocifs.sh script, if you have placed it differently from the default in step 1!
4. Install the init script for bootup with `update-rc.d autocifs defaults`
5. Start AutoCIFS with `service autocifs start` ... the mounted folders will magically appear

AutoCIFS will now completly take care of those mounts by checking the CIFS Server regularily (`INTERVAL`) if its up or down. If its down, it will unmount the shares after 2 check-failures and will auto-remount them as soon as the server is back up. In that case it will also write it to the syslog.

You can also uncomment all lines starting with `#logger` to get a more verbose syslog output (not needed in production)

## Variables explanation

- `SCRIPTPATH` - The path to the AutoCIFS executable (default: /usr/local/bin/autocifs.sh)
- `LOGLEVEL` - Set the desired log level from 0 (disabled) trough 1 (normal logging) to 2 (debug logging)
- `CIFSSERVER` - The CIFS Server you want to mount something from can be either a single IP or a DNS-Name
- `CIFSVERS` - Defines the CIFS Protocol (1, 2.0, 2.1 or 3.0) to be used for checking the Server and is needed to prevent writing "unknown version" warnings in the syslog
- `MOUNTOPT` - Here you can define the classic CIFS Mount options like you would in the fstab (uses good defaults for most scenarios)
- `INTERVAL` - How often should AutoCIFS check the Server? (60seconds is a good default but we use 15seconds for our HA Environment)
- `MOUNTS` - This is a space-separated list of shares to mount for ex. `MOUNTS=( "/share1" "/share2" )`, whereas the share name and mountpath must be the same in this version. In a later version i will also support different shares and mount-paths

## Copyright and License

This little tool was made by Martin Seener (c) 2016
Feel free to contribute! Use feature branches in your forks for new stuff or bugfixes before you submit them to me! And please sign-off your commits!

Released under the MIT License
