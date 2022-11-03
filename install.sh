#!/bin/bash

set -e

GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
DEFAULT_COLOR='\033[0m' # No Color

if ! command -v php &> /dev/null
then
    echo "PHP if not installed"
    exit
fi
PHP_VERSION=$(php --version | grep "PHP "\[0-9] -o)

if [ "${PHP_VERSION}" == "PHP 8" ]
then
  PHP_VERSION=$(php --version | grep "PHP "\[0-9])
  echo "${PHP_VERSION} detected"
else
  echo -e "${RED}Required PHP version not detected! Saeghe needs PHP >= 8.0 ${DEFAULT_COLOR}"
  exit
fi

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
echo -e "Saeghe version: ${GREEN}${SAEGHE_LATEST_RELEASE}${DEFAULT_COLOR}"

CLI_LATEST_RELEASE=$(curl -s -H "Accept: application/vnd.github+json" https://api.github.com/repos/saeghe/cli/releases | grep "tag_name" | grep v\[0-9a-z\.]\\+ -o | head -n 1)
echo -e "CLI version: ${GREEN}${CLI_LATEST_RELEASE}${DEFAULT_COLOR}"

echo -e "Start downloading Saeghe version: ${GREEN}${SAEGHE_LATEST_RELEASE}${DEFAULT_COLOR}"
curl -s -L https://github.com/saeghe/saeghe/zipball/$SAEGHE_LATEST_RELEASE > $SAEGHE_HOME/saeghe.zip

echo -e "Start downloading CLI version: ${GREEN}${CLI_LATEST_RELEASE}${DEFAULT_COLOR}"
curl -s -L https://github.com/saeghe/cli/zipball/$CLI_LATEST_RELEASE > $SAEGHE_HOME/cli.zip

echo -e "${GREEN}Download finished${DEFAULT_COLOR}"

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

if [ "$DEFAULT_SHELL" == "/bin/zsh" ]
then
  echo "Add Saeghe to zsh"
  echo $EXPORT_PATH >> $HOME/.zshrc
else
  echo "Add Saeghe to bash"
  echo $EXPORT_PATH >> $HOME/.bashrc
fi

echo -e "${YELLOW}- Please open a new terminal to start working with Saeghe.${DEFAULT_COLOR}"
echo -e "${YELLOW}- Please add your credential using the credential command. Visit https://saeghe.com/documentations/credential-command ${DEFAULT_COLOR}"
echo -e "${GREEN}Installation finished successfully. Enjoy.${DEFAULT_COLOR}"
