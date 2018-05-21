#!/bin/bash

# target of your bucket, see https://docs.aws.amazon.com/general/latest/gr/rande.html for list of the regions
TARGET='s3://<s3-region>.amazonaws.com/<s3-bucket-name>'

# the directory name in your bucket
SOURCE='/backups'

# the directory path where to restore files
BACKUP_DIR=/home/backups

# put the passphrase that will be setted in backup.sh script
PASSPHRASE=my_passphrase

unset DATE
DATE=$1
mkdir -p "$BACKUP_DIR"

# needed by Boto, for some S3 regions like eu-west-3 (avoid "BackendException: No connection to backend")
# see https://raimue.blog/2015/03/12/backup-with-duply-to-amazon-s3-backendexception-no-connection-to-backend/comment-page-1/#comment-119061 for more explanation
export S3_USE_SIGV4="True"

export PASSPHRASE

[ -z $1 ] && DATE=$(date +'%Y-%m-%d')
printf "## Restoring backups to $DATE in $BACKUP_DIR at 23:59:59 from $SOURCE\n"
duplicity restore -t "$DATE""T23:59:59" ${TARGET}${SOURCE} "$BACKUP_DIR"
