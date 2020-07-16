#!/bin/bash

echo <<EOF> /lib/systemd/system-sleep/psmouse-refresh.sh
#!/bin/bash

# $1 is the state (pre or post)-sleep
if [[ $1 == post ]]; then
    modprobe -r psmouse
    modprobe psmouse
fi

EOF

chmod +x /lib/systemd/system-sleep/psmouse-refresh.sh