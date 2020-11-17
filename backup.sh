#!/bin/bash

##############################
#
# Backup script
#
#############################

source /etc/environment
function not_zero_exit() {
    EXIT_CODE="$1"
    echo Command exit code was: $EXIT_CODE
    if [[ "$EXIT_CODE" != 0 && "$EXIT_CODE" != 1 ]]; then
        exit $EXIT_CODE
    fi
}

if [[ -z "${BACKUP_PASSPHRASE}" ]]; then
    echo $BACKUP_PASSPHRASE
    echo Must set BACKUP_PASSPHRASE environment variable
    exit 1
fi

DOW=`date +%A`
FILE_NAME_PREFIX=$USER
BACKUP_DIR_NAME=$HOME/.backups
TAR_NAME="$BACKUP_DIR_NAME/$FILE_NAME_PREFIX-$DOW.tar"
DIRS_FOR_BACKUP=( \
    "$HOME" \
    "$HOME/.bash*" \
    "$HOME/.vim*" \
    "$HOME/.profile" \
    "$HOME/.password-store" \
    "$HOME/vimwiki" \
    "/etc" \
    "/usr/local/sbin" \
    "/usr/share/ca-certificates" \
)

cat exclude | sed "s,{{HOME}},${HOME},g" | sed "s,{{BACKUP_DIR_NAME}},${BACKUP_DIR_NAME},g" > exclude.tmp

mkdir -p ${BACKUP_DIR_NAME}
tar --exclude-from=exclude.tmp --exclude-caches --exclude-vcs --exclude-backups -zcvf $TAR_NAME ${DIRS_FOR_BACKUP[*]}
rm exclude.tmp
not_zero_exit "$?"

gpg2 --output "$TAR_NAME.gpg" --symmetric --batch --yes --passphrase $BACKUP_PASSPHRASE $TAR_NAME
not_zero_exit "$?"
rm $TAR_NAME

if [[ "$1" == upload ]]; then
    echo Upload to google drive
    #    gdrive upload --parent 1mIDo-TSMYE5OmggQkUi7uY_9qjUwe2RH "$TAR_NAME.gpg"
    cp ${TAR_NAME}.gpg ~/GoogleDrive/backup-new
fi
