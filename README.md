# FidoNode
Complete Fidonet Node system, minimal changes needed to get up&amp;running again.

# Identities, placeholders
The configuration needs to change; the following is a list of the placeholder and what you should substitute it with:<br>
"John Doe"        = Your Name<br>
2:999/456         = Your fidonet node number<br>
2:999/1           = Your fidonet *uplink's* node number<br>
Unicorn BBS       = The name of your system<br>
Bern, Switzerland = Your location<br>

# Instructions

1. Paths
All files in this repository are supposed to be in a folder "C:\fido", accordingly in there you should see the following folders:<br>
\_batch<br>
BinkD<br>
config<br>
FMail<br>
GoldEd<br>
log<br>
msgbase<br>
netmail<br>
nodelist<br>
persmail<br>
transfer<br>

2. Config files<br>
Before being able to start, some configs need to be adjusted.

2.1 Config files: c:\fido\binkd.cfg<br>
Search for all strings that contain "@@" and substitute the values there with your own (see also "# Identities, placeholders" above)

2.2 Config files: c:\fido\golded.cfg<br>
Search for all strings that contain "@@" and substitute the values there with your own (see also "# Identities, placeholders" above)

2.3 Config files: FMail<br>
FMail uses a config tool; go ahead and start c:\fido\fmail\fconfigw32.exe, then make the adjustments in the following menu areas:
- Miscellaneous > General Options > SysOp Name (put in your name)
- Miscellaneous > Addresses 1 > Main (put in your Fidonet node address)
- Miscellaneous > AreaMgr defaults > Origin line (put in your system's name and your location)
- Uplink Manager > 1 (put in your uplink's Fidonet node address and AreaFix password; also make sure that "Origin address" is your Fidonet address)
- Pack Manager (put in your uplink's Fidonet address behind "* via")
- Node Manager (put in your uplink's Fidonet name, address (twice in "System" and "Via system", and enter the AreaMgr and Packet passwords at the bottom)
- Area Manager (define any additional areas that you need (GOLDED and FMAIL_HELP are there as examples)

About area manager: New areas are automatically created once new mail in them has arrived on your system. 

# Firewall
BinkD uses the default BinkP internet port tcp/24554. Make sure that outbound traffic to that port is allowed and that inbound traffic to that port is routed to your Fidonet node system. Don't forget to open the port in the local firewall, as well.


# Daily operation, old school
Just start c:\fido\_batch\binkd.cmd. This should launch BinkD in a window and that's it. You're up&running. Inbound mails are automatically processed; BinkD will launch c:\fido\_batch\FMail_In.cmd when it receives a .pkt file. Outbound mail is not automatically sent, you have to launch c:\fido\_batch\FMail_Out.cmd. This will send normal netmail, routed netmail, direct/crash netmail and echomail.

Finally, just launch c:\fido\golded\golded.exe to start reading your mail.<br>


# Daily operation, the PoSH way
Start c:\fido\_batch\PowerFido.ps1. It will wrap around various Fido programs and let you launch processes, guided through a text style GUI:

 1 - Start GoldEd<br>
 2 - Start GoldNode (compile Nodelist)<br>
<br>
 5 - Tail BinkD log (separate window)<br>
 6 - Tail FMail log (separate window)<br>
 7 - Tail Tosser log (separate window)<br>
<br>
 9 - Send outbound echo and netmail<br>
10 - Manually process inbound echo an netmail<br>
<br>
 X - Exit<br><br>

Which will it be?:



# Licenses
I do not own any of these programs, they are provided here as a convenience to avoid having to hunt for them. The regular download locations are as follows:<br>

BinkD:  http://download.binkd.org/<br>
FMail:  https://sourceforge.net/projects/fmail/<br>
GoldEd: https://github.com/golded-plus/golded-plus<br>

