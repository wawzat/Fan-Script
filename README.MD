**Fan control script for Dell PowerEdge R420

Adapted from https://github.com/TheColetrain/IPMI-Script-Dell-r420
Uses IPMITool to measure temperatures and set fan speeds
If temperature is over setpoint set static fan speed 
or enable/disable dynamic fan control accordingly.
Requires IPMITool to be installed
IPMItool commands use lanplus across the network. iDRAC does not allow
TCP/IP Connection from a server port to the iDRAC Enterprise port unless a VLAN is setup in iDRAC
As an alternative I'm running this from a dedicated Ubuntu server VM container on ProxMox.

Use chmod +x fan_control_svc.sh to make the file executable.

This script is intended to be run as a service under systemd with the following service file
cron can also be used (without the while loop) but this is better.
Two files are required. This script and a systemd service file.
Indented comments below are for the systemd service file
Name the systemd service file "fan_control.service"
Place the file in /etc/systemd/system/
Remove one "#" from each line below. Lines with two ## are meant to remain with one # as comment.

        [Unit]
        Description= fan control service

        [Service]
        #Not run by root, but by user
        User=<USERNAME>
        Type=simple
        #Location of the executable script
        ExecStart=/home/USERNAME/scripts/fan_control_svc.sh
        Restart=always

        [Install]
        WantedBy=multi-user.target

        Load and start the service (as root) with the following commands
        "systemctl enable fan_control.service"
        "systemctl start fan_control.service"

    Check status with "systemctl status fan_control.service"
    If the "fan_control_svc.sh" script is changed issue "sudo systemctl restart fan_control.service"
