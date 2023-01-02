
# clamav-mac

A Non-Graphical ClamAV Antivirus Solution for Mac OS X

I forked and updated this repository for the most recent Brew downloads as a free alternative to ClamXav. clamav-mac sets up real-time directory monitoring and schedules periodic scans. The scripts use ClamAV as an AntiVirus engine and fswatch to actively monitor directories for new or changed files, which are then sent to clamd for scanning.

### Disclaimer
Frankly, it is debatable whether antivirus software is helpful on MacOS after 10.15 with the advent of built-in controls.  See **[Apple's implementation](https://support.apple.com/guide/security/protecting-against-malware-sec469d47bd8/web)**


This work is provided as is without any expressed or implied warranties.  Use this software at your own risk only after reading and understanding the effects of the configuration scripts.

### Prerequisites

All prerequisites  will be automatically installed with Brew. I have tested clamav-mac on Mojave and Ventura ,but it may also work in other versions of OS X.

### Virus Scans

clamav-mac performs two types of scans:

When a file is changed or created, it will be scanned immediately. By default, the /Users directories are monitored.
Scheduled scanning: clamav-ma will perform recursive scans of directories at scheduled times. By default, the entire /Users direectoriesn are scanned once a week.
In all cases, when a virus is found, it is moved to the quarantine folder and an email is send to the administrator.

### Installing
Important Note - the scripts overwrite previous repository configuration files including those for Clamv.  If you need to retain any changes in those files, make copies before running the script.

```
    git clone https://github.com/cayossarian/clamav-mac.git
```

```
    chmod 700 install.sh configuration.sh
```

```
    ./install.sh
```
### Post Install
In order for clamv to scan your files it needs full disk access which is set in macos settings->Privacy and Sercurity->Full Disk Access.  Open the settings and drag clamdscan and clamscan from a finder window into the dialog and enable their access by toggling them on.  Use a terminal to find their locations easily.

    which clamdscan

    which clamscan

### Results 
This configuration  will bootstrap clamav-mac by installing the lastest versions of ClamAV and fswatch from brew. It will schedule a full file system scan once a week and update signatures once a day. It also sets up live monitoring for the $HOME directories. Each of these things can be configured by modifying script variables.

By default, the installation directory is ~/clamav-mac.

### Directory

Contains all logs of the program: `/var/log/clamav`<br/>

Contains all configuration files:


    Cron files: `/var/root/.clamav/`<br/>
    Launch Deamon files: `/Library/LaunchDaemons (plists)`<br/>
    Clamav configuration files: `/opt/homebrew/etc/clamav`


Contains all the malware: `/var/jail`<br/>


Contain the script launch by launchd: `/var/root/.clamav/`<br/>

### Deactivation

    sudo launchctl unload -w /Library/LaunchDaemons/com.clamav_cron.plist

    sudo launchctl unload -w /Library/LaunchDaemons/com.clamav_tr.plist

### Email Notification Setup
The script provides basic Postfix email configuration that works for local machine mailbox addresses but if you need to map from a local machine mailbox address (like somebody@machine.local) to a domain (like somebody@me.com) you'll need to do a bit more configuration:
1. Ensure this generic mapping line is present in `/etc/postfix/main.cf`<br/>  
	smtp_generic_maps=hash:/etc/postfix/generic 
2. Edit `/etc/postfix/generic`, adding mapping lines similar to the examples the email authentication is expecting for the external domain user, (rewrites the FROM header so emails appear to be from the correct user@domain address):
    
    `somebody@machine.local somebodyd@me.com` <br/>
	`root@machine.local somebody@me.com`<br/>

3. Run:<br/>
    `sudo postmap /etc/postfix/generic`
4. Run:<br/>
    `sudo postfix reload`
5. Edit /etc/aliases<br/> 
    `# Put your local aliases here.`<br/>
    `root: somebody@me.com`<br/>
6. Run: 
    `sudo newaliases`
7. Run: 
    `sudo postfix reload`

Test your email configuration by sending an email to root and see if it is forwarded to your own external email:<br/>
In one terminal window Monitor the postfix log: 

    log stream --predicate  '(process == "smtpd") || (process == "smtp")' --info

In a second terminal Send an email:

	echo "Testing my new postfix setup" | mail -s "Test email from `hostname`" root


Watch for email authentication errors or other problems in the log output.  If you have an authentication error check your email name and application specific password in /etc/postfix/sasl_passwd.
Remember if you change the passwords in sasl_passwd, rerun the command:

    sudo postmap /etc/postfix/sasl_passwd


### Final Realtime Antivirus Test
Create a test file Within a ~/Downloads directory

    echo 'X5O!P%@AP[4\PZX54(P^)7CC)7}$EICAR-STANDARD-ANTIVIRUS-TEST-FILE!$H+H*' > clamav-testfile

The file should be moved to /var/jail and you should receive an email regarding the test "virus"

### Authors

* cayossarian, forked from coldnfire

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details

## Acknowledgments

$ coldnfire/clamav-mac

