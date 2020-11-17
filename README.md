* Add environment variable BACKUP_PASSPHRASE that will be used for symetric tar encription
```bash
sudo apt install gnupg2
sudo add-apt-repository ppa:alessandro-strada/ppa
sudo apt-get update
sudo apt-get install google-drive-ocamlfuse
mkdir ~/GoogleDrive
google-drive-ocamlfuse GoogleDrive/
```
* add exclude patterns in `exclude` file. Each in new line. Can use placeholder `{{HOME}}` for user
  home directory.
