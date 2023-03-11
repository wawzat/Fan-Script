# Fan control script for Dell PowerEdge R420

Adapted from https://github.com/TheColetrain/IPMI-Script-Dell-r420
- Uses IPMITool to measure temperatures and set fan speeds
- If temperature is over setpoint set static fan speed or enable/disable dynamic fan control accordingly.
- Requires IPMITool to be installed
- IPMItool commands use lanplus across the network. iDRAC does not allow TCP/IP Connection from a server port to the iDRAC Enterprise port unless a VLAN is setup in iDRAC
- As an alternative I'm running this from a dedicated Ubuntu server VM container on ProxMox.
  
- The bash script "fan_control_svc.sh" is intended to be run as a systemd service under systemd using the "fan_control.service" service file
- cron can also be used (without the while loop) but this is better.
  
- fan_control.service file
    - Update the User= line to the appropriate user account
    - Update the ExecStart= line with the path to the user folder and script
    - Place the fan_control.service file in /etc/systemd/system/
      
 - config_template.txt
    - Rename the file config.txt
    - Edit the IP address, IDRAC username and IDRAC password.
    - Place the config.txt file in an appropriate user folder per the path used in the fan_control.service file.
    
- fan_control_svc.sh file
    - Update the source line with the path to the config.txt file
    - Place the fan_control_svc.sh file in an appropriate user folder per the path used in the fan_control.service file.
    - Use chmod +x fan_control_svc.sh to make the file executable.
  
Check status with "systemctl status fan_control.service"
If the "fan_control_svc.sh" script is changed, issue "sudo systemctl restart fan_control.service"