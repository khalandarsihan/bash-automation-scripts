#!/bin/bash

# This script creates a new user on the local system.
# It will prompt for the username, real name, and password.

# Ensure the script is run with superuser privileges.
if [[ "${UID}" -ne 0 ]]
then
  echo 'Please run with sudo or as root.' >&2
  exit 1
fi

# Prompt for the username.
read -p 'Enter the username to create: ' USER_NAME

# Prompt for the real name.
read -p 'Enter the name of the person who this account is for: ' COMMENT

# Prompt for the password.
read -p 'Enter the password to use for the account: ' PASSWORD

# Create the user with the provided details.
useradd -c "${COMMENT}" -m "${USER_NAME}"

# Check if the useradd command succeeded.
if [[ "${?}" -ne 0 ]]
then
  echo 'The account could not be created.' >&2
  exit 1
fi

# Set the password for the user.
echo "${USER_NAME}:${PASSWORD}" | chpasswd

# Check if the passwd command succeeded.
if [[ "${?}" -ne 0 ]]
then
  echo 'The password for the account could not be set.' >&2
  exit 1
fi

# Force password change on first login.
passwd -e "${USER_NAME}"

# Display the username, password, and the host where the account was created.
echo
echo 'username:'
echo "${USER_NAME}"
echo
echo 'password:'
echo "${PASSWORD}"
echo
echo 'host:'
echo "${HOSTNAME}"
exit 0

