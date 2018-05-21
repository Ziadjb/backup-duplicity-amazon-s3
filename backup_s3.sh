#!/bin/bash

# target of your bucket, see https://docs.aws.amazon.com/general/latest/gr/rande.html for list of the regions
TARGET='s3://<s3-region>.amazonaws.com/<s3-bucket-name>'

# the directory name in your bucket
SOURCE='/backups'

# the TMP dir for dummping of databases
TMP_DBDIR=/tmp/dbdump
MYSQL_PW=secret
MYSQL_USER=root

# choose and set a passphrase that will be use in restore.sh script
PASSPHRASE=my_passphrase

# params for duplicity, eg. if you want to store in RRS mode
PARAMS=' --s3-use-rrs '

MAX_AGE=' 4M '

# list of your databases to dump
DATABASES="database1 \
database2 \
database3 \
database4 \
database5"

# databases
mkdir -p "$TMP_DBDIR"
for dbname in $DATABASES
do
  printf "## Dump database $dbname...\n"
  mysqldump -uroot -p"$MYSQL_PW" --skip-comments -q "$dbname" \
    > "$TMP_DBDIR/$dbname.sql"
done

# duplicity
printf "## Backup S3 in $TARGET using duplicity...\n"
unset MODE
[ "$1" = full ] && MODE=full && printf '(force full backup)\n'

export PASSPHRASE

# needed by Boto, for some S3 regions like eu-west-3 (avoid "BackendException: No connection to backend")
# see https://raimue.blog/2015/03/12/backup-with-duply-to-amazon-s3-backendexception-no-connection-to-backend/comment-page-1/#comment-119061 for more explanation
export S3_USE_SIGV4="True"
duplicity ${MODE} ${PARAMS} --include-globbing-filelist '/home/backup-list.txt' --include "$TMP_DBDIR" --exclude "**" / ${TARGET}${SOURCE}

printf '## Delete old backups\n'
duplicity remove-older-than ${MAX_AGE} ${TARGET}${SOURCE} --force

# backups are encrypted, we can make them accessible

# remove temp files
rm "$TMP_DBDIR"/*.sql