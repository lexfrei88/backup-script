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
    "/home/$USER" \
    "/usr/local/sbin" \
    "/usr/share/ca-certificates" \
)
EXCLUDED_DIRS=( \
    "$BACKUP_DIR_NAME" \
    "/home/${USER}/GoogleDrive" \
    "/home/${USER}/Downloads" \
    "/home/${USER}/Desktop" \
    "/home/${USER}/Pictures" \
    "/home/${USER}/Public" \
    "/home/${USER}/Videos" \
    "/home/${USER}/Music" \
    "/home/${USER}/snap" \
    "/home/${USER}/.npm" \
    "/home/${USER}/.nvm" \
    "/home/${USER}/.m2" \
    "/home/${USER}/.gradle" \
    "/home/${USER}/.cache" \
    "/home/${USER}/.local" \
    "/home/${USER}/.mozilla" \
    "/home/${USER}/.config" \
    "/home/${USER}/.java" \
    "/home/${USER}/.android" \
    "/home/${USER}/.vim/plugged" \
    "/usr/share/ca-certificates/mozilla" \
)

exlude=''
for exluded_dir in ${EXCLUDED_DIRS[@]}; do
    exlude+=" --exclude=$exluded_dir"
done

mkdir -p ${BACKUP_DIR_NAME}
tar $exlude --exclude-vcs --exclude-backups -zcvf $TAR_NAME ${DIRS_FOR_BACKUP[*]}
not_zero_exit "$?"

gpg2 --output "$TAR_NAME.gpg" --symmetric --batch --yes --passphrase $BACKUP_PASSPHRASE $TAR_NAME
not_zero_exit "$?"
rm $TAR_NAME

if [[ "$1" == upload ]]; then
    echo Upload to google drive
#    gdrive upload --parent 1mIDo-TSMYE5OmggQkUi7uY_9qjUwe2RH "$TAR_NAME.gpg"
    cp ${TAR_NAME}.gpg ~/GoogleDrive/backup-new
fi
