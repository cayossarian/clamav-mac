!!! THIS REPOSITORY STAY IN PROGRESS !!!

# Clamav4Mac

The Non-Graphical ClamAV Antivirus Solution for Mac OS X

I forked this as a free alternative to the excellent ClamXav. Clamav4Mac sets up real-time directory monitoring and schedules periodic scans. It uses ClamAV as an AntiVirus engine and fswatch to actively monitor directories for new or changed files, which are then sent to clamd for scanning.


### Prerequisites

All prerequies will be automatically installed. I have tested Clamav4Mac on High Sierra & Mojave , but it may also work in other versions of OS X.

### Virus Scans

Clamav4Mac performs two types of scans:

When a file is changed or created, it will be scanned immediately. By default, the $HOME and Applications directories are monitored.
Scheduled scanning: Clamav4Mac will perform recursive scans of directories at scheduled times. By default, the entire $HOME and /Application is scanned once a week.
In all cases, when a virus is found, it is moved to the quarantine folder and an email is send to the administrator.

### Installing

```
git clone https://github.com/coldnfire/clamav-mac.git
```

```
chmod 700 install.sh configuration.sh
```

```
./install.sh
```

This will bootstrap Clamav4Mac by building the lastest versions of ClamAV and fswatch from brew. It will schedule a full file system scan once a week and update signatures once a day. It also sets up live monitoring for the $HOME and /Applications directories. Each of these things can be configured by modifying script variables.

By default, the installation directory is ~/clamav-mac.

### Directory

Contain all logs of the program

```
/var/log/clamav
```

Contain all configuration files

```
/usr/local/etc/clamav/
```

Contain all the malware

```
/var/jail
```

Contain the script launch by launchd

```
/var/root/.clamav/
```

### Deactivation

With the root user :

```
launchctl unload -w /Library/LaunchDaemons/com.clamav_cron.plist
```

```
launchctl unload -w /Library/LaunchDaemons/com.clamav_tr.plist
```

## Authors

* **coldnfire** 

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details

## Acknowledgments

$ coldnfire/clamav-mac

