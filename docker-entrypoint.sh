#!/bin/sh
set -e

# Determine requested locale (LC_ALL takes precedence)
REQ_LOCALE="${LC_ALL:-${LANG:-C.UTF-8}}"

case "$REQ_LOCALE" in
  C|POSIX|C.UTF-8)
    # nothing to do
    ;;
  *)
    # split name and charset if provided (e.g. sk_SK.UTF-8)
    if echo "$REQ_LOCALE" | grep -q '\.'; then
      LOCALE_NAME=${REQ_LOCALE%%.*}
      CHARSET=${REQ_LOCALE##*.}
    else
      LOCALE_NAME=${REQ_LOCALE}
      CHARSET="UTF-8"
    fi

    # if locale not available, try to generate it
    if ! locale -a 2>/dev/null | grep -iq "^${REQ_LOCALE}$"; then
      echo "Generating locale ${REQ_LOCALE}"
      if command -v localedef >/dev/null 2>&1; then
        localedef -i "${LOCALE_NAME}" -f "${CHARSET}" "${REQ_LOCALE}" || true
      else
        # fallback: uncomment in /etc/locale.gen and run locale-gen
        sed -i "/^# *${REQ_LOCALE}$/s/^# *//g" /etc/locale.gen || true
        locale-gen "${REQ_LOCALE}" || true
      fi
    fi
    ;;
esac

echo "Locale set to:"
echo "$(locale)"

echo "Timezone set to: $TZ"

# Activate virtualenv
if [ -f /root/weewx-venv/bin/activate ]; then
  # shellcheck disable=SC1091
  . /root/weewx-venv/bin/activate
  PATH="/root/weewx-venv/bin:${PATH}"
fi

# Ensure data dirs
mkdir -p /root/weewx-data /root/weewx-html
chmod 755 /root/weewx-data /root/weewx-html || true

# Check if weewx config exists, if not create default one
if [ ! -f /root/weewx-data/weewx.conf ]; then
  echo "Creating default weewx configuration"
  weectl station create /root/weewx-data/ --driver=weewx.drivers.simulator --html-root=/root/weewx-html/ --register=n --no-prompt
  # add content of /root/logging.conf to end of weewx.conf
  if [ -f /root/logging.conf ]; then
    echo "" >> /root/weewx-data/weewx.conf
    cat /root/logging.conf >> /root/weewx-data/weewx.conf
  fi
fi

# If the first arg is a flag, prepend the default command
if [ "${1#-}" != "$1" ]; then
  set -- weewxd "$@"
fi

exec "$@"