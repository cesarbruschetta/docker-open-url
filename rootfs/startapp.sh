#!/usr/bin/with-contenv sh

set -e # Exit immediately if a command exits with a non-zero status.
set -u # Treat unset variables as an error.

export HOME=/config
mkdir -p /config/profile
firefox --version
exec /usr/bin/firefox_wrapper \
    --url "${FIREFOX_URL:-about:blank}" \
    --profile /config/profile \
    --setDefaultBrowser >> /config/log/firefox/output.log 2>> /config/log/firefox/error.log & 

echo "Firefox started"
vncdo -s localhost key space

echo "Sleep for 60 seconds"
sleep 60

vncdo -s localhost mousemove 200 300
echo "VNC mouse moved to 200, 300"

vncdo -s localhost key space 
echo "VNC key space"

echo "Docker live..."
sleep infinity