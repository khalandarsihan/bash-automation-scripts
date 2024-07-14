#!/bin/bash

# Ensure the script is being executed with superuser privileges.
if [[ "${UID}" -ne 0 ]]; then
  echo "Please run with sudo or as root." >&2
  exit 1
fi

# If the user doesn't supply at least one argument, then give them help.
if [[ "${#}" -lt 1 ]]; then
  echo "Usage: ${0} USER_NAME [COMMENT]..." >&2
  exit 1
fi

# The first parameter is the user name.
USER_NAME="${1}"

# The rest of the parameters are for the account comments.
shift
COMMENT="${*}"

# Generate a password.
PASSWORD=$(date +%s%N | sha256sum | head -c48)

# Create the user with the comment and home directory.
useradd -c "${COMMENT}" -m "${USER_NAME}" >/dev/null 2>&1

# Check to see if the useradd command succeeded.
if [[ "${?}" -ne 0 ]]; then
  echo "The account could not be created." >&2
  exit 1
fi

# Set the password for the user using chpasswd.
echo "${USER_NAME}:${PASSWORD}" | chpasswd >/dev/null 2>&1

# Check to see if the chpasswd command succeeded.
if [[ "${?}" -ne 0 ]]; then
  echo "The password for the account could not be set." >&2
  exit 1
fi

# Force password change on first login.
passwd -e "${USER_NAME}" >/dev/null 2>&1

# Check to see if the passwd command succeeded.
if [[ "${?}" -ne 0 ]]; then
  echo "The password expiry for the account ${USER_NAME} could not be set." >&2
  exit 1
fi

# Display the username, password, and the host where the user was created.
echo
echo "username:"
echo "${USER_NAME}"
echo
echo "password:"
echo "${PASSWORD}"
echo
echo "host:"
echo "${HOSTNAME}"
echo

exit 0

