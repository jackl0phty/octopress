---
layout: post
title: "How to Recover the Password for the Cisco ASA 5505 Adaptive Security Appliance"
date: 2013-01-18 23:13
author: Gerald L. Hevener Jr., M.S.
comments: true
categories: 
---
This blog will discuss how to reset the password on Cisco's ASA 5505 Adaptive Security Appliance.  First I will assume you are using Cisco's gudie for recovering your password located at http://www.cisco.com/en/US/docs/security/asa/asa71/configuration/guide/trouble.pdf .  Start at page 7 entited "Performing password Recovery for the ASA 5500 Series Adaptive Security Appliance.
<!-- more -->
I won't copy what's in Cisco's guide but I'll add the following:

1.  Below is what steps 4 - 8 actually look like on Cisco's ASA 5505:
{% codeblock Output from Cisco ASA 5505 %}
rommon #1> confreg
Current Configuration Register: 0x00000000
Configuration Summary:
boot ROMMON
Do you wish to change this configuration? y/n [n]: y
enable boot to ROMMON prompt? y/n [n]:
enable TFTP netboot? y/n [n]:
enable Flash boot? y/n [n]:
select specific Flash image index? y/n [n]:
disable system configuration? y/n [n]: y
go to ROMMON prompt if netboot fails? y/n [n]:
enable passing NVRAM file specs in auto-boot mode? y/n [n]:
disable display of BREAK or ESC key prompt during auto-boot? y/n [n]:
Current Configuration Register: 0x00000040
Configuration Summary:
boot ROMMON
ignore system configuration
Update Config Register (0x40) in NVRAM...
rommon #2>
Next reload the ASA by typing boot.
rommon #2> boot
Launching BootLoader...
Default configuration file contains 1 entry.
Searching / for images to boot.
Loading /asa722-k8.bin... Booting...
###############################################################################################################################################################################################
256MB RAM
Total SSMs found: 0
Total NICs found: 10
88E6095 rev 2 Gigabit Ethernet @ index 09 MAC:
88E6095 rev 2 Ethernet @ index 08 MAC:
88E6095 rev 2 Ethernet @ index 07 MAC:
88E6095 rev 2 Ethernet @ index 06 MAC:
88E6095 rev 2 Ethernet @ index 05 MAC: 
88E6095 rev 2 Ethernet @ index 04 MAC: 
88E6095 rev 2 Ethernet @ index 03 MAC: 
88E6095 rev 2 Ethernet @ index 02 MAC: 
88E6095 rev 2 Ethernet @ index 01 MAC: 
y88acs06 rev16 Gigabit Ethernet @ index 00 MAC:
Licensed features for this platform:
Maximum Physical Interfaces : 8
VLANs : 3, DMZ Restricted
Inside Hosts : 10
Failover : Disabled
VPN-DES : Enabled
VPN-3DES-AES : Enabled
VPN Peers : 10
WebVPN Peers : 2
Dual ISPs : Disabled
VLAN Trunk Ports : 0
This platform has a Base license.
Encryption hardware device : Cisco ASA-5505 on-board accelerator (revision 0x0)
Boot microcode : #CNlite-MC-Boot-Cisco-1.2
SSL/IKE microcode: #CNlite-MC-IPSEC-Admin-3.03
IPSec microcode : #CNlite-MC-IPSECm-MAIN-2.04
--------------------------------------------------------------------------
. .
| |
||| |||
.|| ||. .|| ||.
.:||| | |||:..:||| | |||:.
C i s c o S y s t e m s
--------------------------------------------------------------------------
Cisco Adaptive Security Appliance Software Version )
 
****************************** Warning *******************************
This product contains cryptographic features and is
subject to United States and local country laws
governing, import, export, transfer, and use.
Delivery of Cisco cryptographic products does not
imply third-party authority to import, export,
distribute, or use encryption. Importers, exporters,
distributors and users are responsible for compliance
with U.S. and local country laws. By using this
product you agree to comply with applicable laws and
regulations. If you are unable to comply with U.S.
and local laws, return the enclosed items immediately.
A summary of U.S. laws governing Cisco cryptographic
products may be found at:
http://www.cisco.com/wwl/export/crypto/tool/stqrg.html
If you require further assistance please contact us by
sending email to export@cisco.com.
******************************* Warning *******************************
Copyright (c) 1996-2006 by Cisco Systems, Inc.
Restricted Rights Legend
Use, duplication, or disclosure by the Government is
subject to restrictions as set forth in subparagraph
(c) of the Commercial Computer Software - Restricted
Rights clause at FAR sec. 52.227-19 and subparagraph
(c) (1) (ii) of the Rights in Technical Data and Computer
Software clause at DFARS sec. 252.227-7013.
Cisco Systems, Inc.
170 West Tasman Drive
San Jose, California 95134-1706
Ignoring startup configuration as instructed by configuration register.
INFO: Converting to disk0:/
Type help or '?' for a list of available commands.
ciscoasa>
{% endcodeblock %}
2.  You should follow steps 9 - 12 exactly as in Cisco's guide.
3.  I would like to add to Cisco's step 13.  Cisco uses the command "password password" which should actually be "passwd password".
4.  Cisco's step 14 is where the fun begins!  Cisco says to type the command "config-register value" where value is the number you recorded in step 5.  THIS IS WRONG WRONG WRONG!!!!!.   If you follow Cisco's step 14 and then step 15, yes you will have successfully reset your password, but if you reboot your ASA or loose power your ASA will stop at the ROMMON prompt (i.e. rommon #1>).  Instead, in step 14 you should type "config-register 0x10011" and then precede to step 15.  Then, if you ever reboot you ASA or loose power, it should fully reboot and not be stuck at the rommon #1> prompt.

