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
    if [[ "$EXIT_CODE" != 0 ]]; then
        exit $EXIT_CODE
    fi
}

if [[ -z "${BACKUP_PASSPHRASE}" ]]; then
    echo $BACKUP_PASSPHRASE
    echo Must set BACKUP_PASSPHRASE environment variable
    exit 1
fi

DOW=`date +%A`
FILE_NAME_PREFIX='alex-new'
BACKUP_DIR_NAME='/media/alex/tools/backups'
TAR_NAME="$BACKUP_DIR_NAME/$FILE_NAME_PREFIX-$DOW.tar"
DIRS_FOR_BACKUP=("/home/alex" "/usr/local/sbin" "/usr/share/ca-certificates")
EXCLUDED_DIRS=("/home/alex/Downloads" "/home/alex/.m2" "/home/alex/.cache" "/home/alex/.local/share/Trash" "/home/alex/.gradle")

exlude=''
for exluded_dir in ${EXCLUDED_DIRS[@]}; do
    exlude+=" --exclude=$exluded_dir"
done

tar $exlude -zcvf $TAR_NAME ${DIRS_FOR_BACKUP[*]}
not_zero_exit "$?"

gpg2 --output "$TAR_NAME.gpg" --symmetric --batch --yes --passphrase $BACKUP_PASSPHRASE $TAR_NAME
not_zero_exit "$?"
rm $TAR_NAME

if [[ $DOW = 'Wednesday' ]]; then
    echo Today is wednsday so upload to google drive
    gdrive upload --parent 1mIDo-TSMYE5OmggQkUi7uY_9qjUwe2RH "$TAR_NAME.gpg"
else
    echo Not a Wednsday so don\'t upload to google drive
fi
