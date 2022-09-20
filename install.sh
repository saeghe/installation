#!/bin/bash

set -e

USER=${USER:-$(id -u -n)}
HOME="${HOME:-$(getent passwd $USER 2>/dev/null | cut -d: -f6)}"
HOME="${HOME:-$(eval echo ~$USER)}"
SAEGHE_HOME=$HOME/.saeghe
SAEGHE_SOURCE_PATH=$HOME/.saeghe/saeghe
SAEGHE_PACKAGES_PATH=$SAEGHE_SOURCE_PATH/Packages
SAEGHE_CLI_PACKAGES_PATH=$SAEGHE_SOURCE_PATH/Packages/saeghe/cli

echo "Make Saeghe directory"
mkdir -p $SAEGHE_HOME

SAEGHE_LATEST_RELEASE=$(curl -s -H "Accept: application/vnd.github+json" https://api.github.com/repos/saeghe/saeghe/releases | grep "tag_name" | grep v\[0-9a-z\.]\\+ -o | head -n 1)
echo Saeghe version: $SAEGHE_LATEST_RELEASE

CLI_LATEST_RELEASE=$(curl -s -H "Accept: application/vnd.github+json" https://api.github.com/repos/saeghe/cli/releases | grep "tag_name" | grep v\[0-9a-z\.]\\+ -o | head -n 1)
echo CLI version: $CLI_LATEST_RELEASE

echo Start downloading version $SAEGHE_LATEST_RELEASE
curl -s -L https://github.com/saeghe/saeghe/zipball/$SAEGHE_LATEST_RELEASE > $SAEGHE_HOME/saeghe.zip

echo Start downloading version $CLI_LATEST_RELEASE
curl -s -L https://github.com/saeghe/cli/zipball/$CLI_LATEST_RELEASE > $SAEGHE_HOME/cli.zip

echo "Download finished"

echo "Install Saeghe"
rm -fR $SAEGHE_SOURCE_PATH
unzip -q -o $HOME/.saeghe/saeghe.zip -d $SAEGHE_HOME
SAEGHE_DIRECTORY=$(ls $HOME/.saeghe | grep saeghe-saeghe)
mv $SAEGHE_HOME/$SAEGHE_DIRECTORY $SAEGHE_SOURCE_PATH

echo "Install CLI"
rm -fR $SAEGHE_CLI_PACKAGES_PATH
unzip -q -o $HOME/.saeghe/cli.zip -d $SAEGHE_PACKAGES_PATH
mkdir -p $SAEGHE_PACKAGES_PATH/saeghe
CLI_DIRECTORY=$(ls $SAEGHE_PACKAGES_PATH | grep saeghe-cli)
mv $SAEGHE_PACKAGES_PATH/$CLI_DIRECTORY $SAEGHE_CLI_PACKAGES_PATH

echo "Make credential file"
cp $SAEGHE_SOURCE_PATH/credentials.example.json $SAEGHE_SOURCE_PATH/.credential

DEFAULT_SHELL=$(echo $SHELL)

EXPORT_PATH='export PATH="$PATH:'$SAEGHE_SOURCE_PATH'"'

if [[ "$DEFAULT_SHELL" == "/bin/zsh" ]]
then
  echo "Add Saeghe to zsh"
  echo $EXPORT_PATH >> $HOME/.zshrc
  zsh
  source $HOME/.zshrc
else
  echo "Add Saeghe to bash"
  echo $EXPORT_PATH >> $HOME/.bashrc
  bash
  source $HOME/.bahrc
fi

echo Installation finished successfully. Enjoy.
