#!/bin/sh

# Install Homebrew
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

echo "Select a configuration for this workstation: "

PS3='Choose configuration (1-5, 6 to cancel): '
# shellcheck disable=SC2039
options=("Software developer" "Graphics-Designer" "Administrator" "All" "Update-All" "Cancel")
config="no-selection"

# shellcheck disable=SC2039
select opt in "${options[@]}"
do
    case $opt in
        "Software developer")
            config="software"
            break
            ;;
        "Graphics-Designer")
            config="graphic"
            break
            ;;
        "Administrator")
            config="admin"
            break
            ;;
        "All")
            config="all"
            break
            ;;
        "Update-All")
            config="update-all"
#            echo "you chose choice $REPLY which is $opt"
            break
            ;;
        "Cancel")
            break
            ;;
        *) echo "Unknown option '$REPLY', try again";;
    esac
done

# shellcheck disable=SC2039
if [ "$config" == "no-selection" ]; then
    echo "User cancelled, exiting ..."
    exit 1
fi

echo "Selected config: $opt ($config) ..."

# Install ansible
brew install ansible

# Install mac-cli for mac app store
brew install mas

# create directory for ansible playbooks in download folder
DIR_INST_PLAYBOOKS=$HOME/Downloads/sanid_installer/playbooks
mkdir -p "$DIR_INST_PLAYBOOKS"

GIT_REPO="https://raw.githubusercontent.com/sanidgmbh/macos-workstation-installer/main/playbooks"

# shellcheck disable=SC2039
SELECTED_PLAYBOOKS=()
# set selected playbooks for installation
case $config in
  "update-all")
      # shellcheck disable=SC2039
      SELECTED_PLAYBOOKS=("update-appstore-apps.yml" "update-brew-apps.yml")
      ;;
  "all")
      # shellcheck disable=SC2039
      SELECTED_PLAYBOOKS=(
        "admin-appstore-apps.yml"
        "admin-brew-apps.yml"
        "default-appstore-apps.yml"
        "default-brew-apps.yml"
        "graphic-appstore-apps.yml"
        "graphic-brew-apps.yml"
        "software-appstore-apps.yml"
        "software-brew-apps.yml"
      )
      ;;
  *)
      # shellcheck disable=SC2039
      SELECTED_PLAYBOOKS=(
        "default-appstore-apps.yml"
        "default-brew-apps.yml"
        "$config-appstore-apps.yml"
        "$config-brew-apps.yml"
      )
      ;;
esac

echo "Home is '$HOME'"

# shellcheck disable=SC2039
for entry in "${SELECTED_PLAYBOOKS[@]}"
do
  echo "Downloading $entry ..."
  curl --create-dirs --output "$DIR_INST_PLAYBOOKS/$entry" "$GIT_REPO/$entry"
done


for entry in "$DIR_INST_PLAYBOOKS"/*
do
  echo "running ansible-playbook $entry"
  ansible-playbook "$entry"
done

# remove installer directory
rm -rf ~/Downloads/sanid_installer
