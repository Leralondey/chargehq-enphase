# Charge HQ + Enphase + Synology


This simple script allows your to upload your local Enphase Solar Energy data to Charge HQ application. It is an excellent application which allows you to charge your Tesla / EV with your excess solar being generated. App doesn't have direct integration with Enphase thus this script comes in handy. 


**Charge HQ:** https://chargehq.net

**Push API Integration:** https://chargehq.net/kb/push-api

**Enphase:** https://enphase.com/en-au

## Script Details

This script works with v7.x firmware of Enphase which needs login details to generate a JWT token. Although the expiry is long, it should automatically renew token when expired.

**Tested on:**  7.6.172 Enphase + Synology DS218play DSM 7.2.1-69057 Update 4 . Reported working on [Envoy Firmware D8.2.114](https://github.com/khandelwalpiyush/chargehq-enphase/issues/1) as well

It is a shell script which can be run on a DSM 7.2.1-69057 Update 4. Please change the following section


```
# Add Charge HQ api_key and envoy ip below and log_file_path location

api_key=''             # Get this from Charge HQ Application
envoy_username=''      # Your login username for Enphase
envoy_password=''      # Your login password for Enphase
envoy_serial_number='' # Your serial number for Enphase
envoy_local_ip=''      # Your local IP address for Enphase
log_file_path=''       # Log Location - easy for troubleshooting

## To not log simply delete all reference to '>> $log_file_path'

```

Example Data

```
# Add Charge HQ api_key and envoy ip below and log_file_path location

api_key='51f1f67d-67f9-4a1b-bba8-5b82c7f752be' # Get this from Charge HQ Application (Push API)
envoy_username='emailaddress@gmail.com' # Your login username for Enphase
envoy_password='supersecretP@$$w0rd' # Your login password for Enphase
envoy_serial_number='9836827386328632' # Your serial number for Enphase
envoy_local_ip='192.168.1.1' # Your local IP address for Enphase
log_file_path='/home/pi/chargehq/chargehq.log' # Log Location - easy for troubleshooting

## To not log simply delete all reference to '>> $log_file_path'

```

## Automation

The script needs to run as a triggered task scheduler. Below links are just example for reference

https://kb.synology.com/en-us/DSM/help/DSM/AdminCenter/system_taskscheduler?version=7

Once running, the script will **upload data to Charge HQ every 30 seconds** per their recommendation.
