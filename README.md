# backup-duplicity-amazon-s3

First install duplicity for backup utility, and boto for Amazon AWS S3 connexion (Debian like installation), website : http://duplicity.nongnu.org/
```
$ sudo apt-get install duplicity python-boto
```

Configure Boto with credentials of your bucket (use your favorite editor like nano or vim..)
See how to get an S3 bucket and credentials : https://docs.aws.amazon.com/AmazonS3/latest/gsg/GetStartedWithS3.html
```
$ sudo nano /etc/boto.cfg
```

```
[Credentials]
aws_access_key_id = YOUR_ACCES_ID
aws_secret_access_key = YOUR_SECRET_KEY

[Boto]
# If using SSL, set to True
is_secure = False
# If using SSL, unmute and provide absolute path to local CA certificate
# ca_certificates_file = /absolute/path/to/ca.crt
```

Next adapt your backup-list.txt, backup.sh and restore.sh script
Then type
```
$ sudo chmod +x /path/backup_s3.sh
$ sudo chmod +x /path/restore_s3.sh
```

Then adapt your cron. Here, I make an incremental backup everyday and a full backup once a month. The first time will automatically be full backup 
```
$ sudo crontab -e
```

```
0 2 1    * * /usr/bin/ionice -c2 -n5 /usr/bin/nice -n15 /home/bin/backup_s3.sh full
0 2 2-31 * * /usr/bin/ionice -c2 -n5 /usr/bin/nice -n15 /home/bin/backup_s3.sh
```

Enjoy...