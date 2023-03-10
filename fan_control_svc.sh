#!/bin/bash

#Tested to work on Dell PowerEdge R420
#Adapted from https://github.com/TheColetrain/IPMI-Script-Dell-r420
#Uses IPMITool to measure temperatures and set fan speeds
#If temperature is over setpoint set static fan speed 
#or enable/disable dynamic fan control accordingly.
#Requires IPMITool to be installed
#IPMItool commands use lanplus across the network. iDRAC does not allow
#TCP/IP Connection from a server port to the iDRAC Enterprise port unless a VLAN is setup in iDRAC
#As an alternative I'm running this from a dedicated Ubuntu server VM container on ProxMox.

#This script is intended to be run as a service under systemd with the following service file
#cron can also be used (without the while loop) but this is better.
#Two files are required. This script and a systemd service file.
#Indented comments below are for the systemd service file
#Name the systemd service file "fan_control.service"
#Place the file in /etc/systemd/system/
#Remove one "#" from each line below. Lines with two ## are meant to remain with one # as comment.

        #[Unit]
        #Description= fan control service

        #[Service]
        ##Not run by root, but by user
        #User=<USERNAME>
        #Type=simple
        ##Location of the executable script
        #ExecStart=/home/USERNAME/scripts/fan_control_svc.sh
        #Restart=always

        #[Install]
        #WantedBy=multi-user.target

        #Load and start the service (as root) with the following commands
        #"systemctl enable fan_control.service"
        #"systemctl start fan_control.service"

    #Check status with "systemctl status fan_control.service"
    #If the "fan_control_svc.sh" script is changed issue "sudo systemctl restart fan_control.service"

source /home/jlucas/scripts/config.txt

#Works with 3 variables, Inlet temp (part 2A)
#and CPU #1 & #2 temperatures (part 2B)

#### part one - Max temp setpoints
HIGHTEMP=27
CPU1MAX=50
CPU2MAX=49
INC=1

####part 2A
HIGHTEMP2=$((HIGHTEMP - INC))
HIGHTEMP3=$((HIGHTEMP2 - INC))
HIGHTEMP4=$((HIGHTEMP3 - INC))
HIGHTEMP5=$((HIGHTEMP4 - INC))
HIGHTEMP6=$((HIGHTEMP5 - INC))
HIGHTEMP7=$((HIGHTEMP6 - INC))

echo HIGHTEMP "$HIGHTEMP"
echo HIGHTEMP2 "$HIGHTEMP2"
echo HIGHTEMP3 "$HIGHTEMP3"
echo HIGHTEMP4 "$HIGHTEMP4"
echo HIGHTEMP5 "$HIGHTEMP5"
echo HIGHTEMP6 "$HIGHTEMP6"
echo HIGHTEMP7 "$HIGHTEMP7"

#### Part 2B
#Temperature for both CPU's are checked as a safety mechanism in case
#a CPU is running hotter than the inlet air temp.

CPU1MAX2=$((CPU1MAX - INC))
CPU2MAX2=$((CPU2MAX - INC))
CPU1MAX3=$((CPU1MAX2 - INC))
CPU2MAX3=$((CPU2MAX2 - INC))
CPU1MAX4=$((CPU1MAX3 - INC))
CPU2MAX4=$((CPU2MAX3 - INC))
CPU1MAX5=$((CPU1MAX4 - INC))
CPU2MAX5=$((CPU2MAX4 - INC))
CPU1MAX6=$((CPU1MAX5 - INC))
CPU2MAX6=$((CPU2MAX5 - INC))
CPU1MAX7=$((CPU1MAX6 - INC))
CPU2MAX7=$((CPU2MAX6 - INC))

echo CPU1MAX "$CPU1MAX"
echo CPU2MAX "$CPU2MAX"
echo CPU1MAX2 "$CPU1MAX2"
echo CPU2MAX2 "$CPU2MAX2"
echo CPU1MAX3 "$CPU1MAX3"
echo CPU2MAX3 "$CPU2MAX3"
echo CPU1MAX4 "$CPU1MAX4"
echo CPU2MAX4 "$CPU2MAX4"
echo CPU1MAX5 "$CPU1MAX5"
echo CPU2MAX5 "$CPU2MAX5"
echo CPU1MAX6 "$CPU1MAX6"
echo CPU2MAX6 "$CPU2MAX6"
echo CPU1MAX7 "$CPU1MAX7"
echo CPU2MAX7 "$CPU2MAX7"

####Part 3

#Fan speed setpoints.
#Hex conversion link https://www.hexadecimaldictionary.com/hexadecimal/0xf/

FS22=0x16
FS20=0x14
FS18=0x12
FS16=0x10
FS14=0xe
FS12=0xc
FS10=0xa

#####Part 4

#Get temp measurements from IPMITool.
#INLET TEMP, CPU1 & CPU2

while ((1)) ; do
    TEMPINLET=`ipmitool -I lanplus -H $IDRACIP -U $IDRACUSER -P $IDRACPASSWORD sdr type temperature \
    | grep "Temp" | cut -d"|" -f5 | cut -d" " -f2 | sed -n 1p`
    TEMPCPU1=`ipmitool -I lanplus -H $IDRACIP -U $IDRACUSER -P $IDRACPASSWORD sdr type temperature \
    | grep "Temp" | cut -d"|" -f5 | cut -d" " -f2 | sed -n 2p`
    TEMPCPU2=`ipmitool -I lanplus -H $IDRACIP -U $IDRACUSER -P $IDRACPASSWORD sdr type temperature \
    | grep "Temp" | cut -d"|" -f5 | cut -d" " -f2 | sed -n 3p`

    TODAY=$(TZ=":US/Pacific" date)
    echo $TODAY " -- current temperature --"
    echo INLET AIR TEMP "$TEMPINLET" C
    echo CPU 1 TEMP     "$TEMPCPU1"  C
    echo CPU 2 TEMP     "$TEMPCPU2"  C

    # part 5 - Measure temperatures and set fixed fan speeds or dynamic fan control accordingly. 
    if [[ "$TEMPINLET" > "$HIGHTEMP" ||
          "$TEMPCPU1" > "$CPU1MAX" ||
          "$TEMPCPU2" > "$CPU2MAX" ]]
      then
        ipmitool -I lanplus -H $IDRACIP -U $IDRACUSER -P $IDRACPASSWORD raw 0x30 0x30 0x01 0x01
        echo "enable dynamic fan control"

    #22
    elif [[ "$TEMPINLET" > "$HIGHTEMP2" ||
          "$TEMPCPU1" > "$CPU1MAX2" ||
          "$TEMPCPU2" > "$CPU2MAX2" ]]
      then
        ipmitool -I lanplus -H $IDRACIP -U $IDRACUSER -P $IDRACPASSWORD raw 0x30 0x30 0x01 0x00
        ipmitool -I lanplus -H $IDRACIP -U $IDRACUSER -P $IDRACPASSWORD raw 0x30 0x30 0x02 0xff "$FS22"
        echo "--> Set fans to 22%"

    #20
    elif [[ "$TEMPINLET" > "$HIGHTEMP3" ||
            "$TEMPCPU1" > "$CPU1MAX3" ||
            "$TEMPCPU2" > "$CPU2MAX3"  ]]
      then
        ipmitool -I lanplus -H $IDRACIP -U $IDRACUSER -P $IDRACPASSWORD raw 0x30 0x30 0x01 0x00
        ipmitool -I lanplus -H $IDRACIP -U $IDRACUSER -P $IDRACPASSWORD raw 0x30 0x30 0x02 0xff "$FS20"
        echo "--> Set fans to 20%"

    #18
    elif [[ "$TEMPINLET" > "$HIGHTEMP4" ||
            "$TEMPCPU1" > "$CPU1MAX4" ||
            "$TEMPCPU2" > "$CPU2MAX4"  ]]
      then
        ipmitool -I lanplus -H $IDRACIP -U $IDRACUSER -P $IDRACPASSWORD raw 0x30 0x30 0x01 0x00
        ipmitool -I lanplus -H $IDRACIP -U $IDRACUSER -P $IDRACPASSWORD raw 0x30 0x30 0x02 0xff "$FS18"
        echo "--> Set fans to 18%"

    #16
    elif [[ "$TEMPINLET" > "$HIGHTEMP5"  ||
            "$TEMPCPU1" > "$CPU1MAX5" ||
            "$TEMPCPU2" > "$CPU2MAX5"  ]]
      then
        ipmitool -I lanplus -H $IDRACIP -U $IDRACUSER -P $IDRACPASSWORD raw 0x30 0x30 0x01 0x00
        ipmitool -I lanplus -H $IDRACIP -U $IDRACUSER -P $IDRACPASSWORD raw 0x30 0x30 0x02 0xff "$FS16"
        echo "--> Set fans to 16%"

    #14
    elif [[ "$TEMPINLET" > "$HIGHTEMP6"  ||
            "$TEMPCPU1" > "$CPU1MAX6" ||
            "$TEMPCPU2" > "$CPU2MAX6"  ]]
      then
        ipmitool -I lanplus -H $IDRACIP -U $IDRACUSER -P $IDRACPASSWORD raw 0x30 0x30 0x01 0x00
        ipmitool -I lanplus -H $IDRACIP -U $IDRACUSER -P $IDRACPASSWORD raw 0x30 0x30 0x02 0xff "$FS14"
        echo "--> Set fans to 14%"

    #12
    elif [[ "$TEMPINLET" > "$HIGHTEMP7"  ||
            "$TEMPCPU1" > "$CPU1MAX7" ||
            "$TEMPCPU2" > "$CPU2MAX7"  ]]
      then
        ipmitool -I lanplus -H $IDRACIP -U $IDRACUSER -P $IDRACPASSWORD raw 0x30 0x30 0x01 0x00
        ipmitool -I lanplus -H $IDRACIP -U $IDRACUSER -P $IDRACPASSWORD raw 0x30 0x30 0x02 0xff "$FS12"
        echo "--> Set fans to 12%"

    #anything less is 10
    else
        ipmitool -I lanplus -H $IDRACIP -U $IDRACUSER -P $IDRACPASSWORD raw 0x30 0x30 0x01 0x00
        ipmitool -I lanplus -H $IDRACIP -U $IDRACUSER -P $IDRACPASSWORD raw 0x30 0x30 0x02 0xff "$FS10"
        echo "--> Set fans to 10%"

    fi
    sleep 15
done
