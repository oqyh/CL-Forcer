# [ANY] CL-Forcer (1.0.4)
https://forums.alliedmods.net/showthread.php?t=338347

### CL Forcer ( Force Client To Download-Table With Reconnect )

![alt text](https://github.com/oqyh/CL-Forcer/blob/main/img/1.png?raw=true)

![alt text](https://github.com/oqyh/CL-Forcer/blob/main/img/2.png)
![alt text](https://github.com/oqyh/CL-Forcer/blob/main/img/3.png)
![alt text](https://github.com/oqyh/CL-Forcer/blob/main/img/4.png)

![alt text](https://github.com/oqyh/CL-Forcer/blob/main/img/allowddownload1.jpg)
![alt text](https://github.com/oqyh/CL-Forcer/blob/main/img/cl_allowdupload1.jpg)
![alt text](https://github.com/oqyh/CL-Forcer/blob/main/img/downloadfiltalr%20all.jpg)

## .:[ ConVars ]:.
```
//## Enable CL_Forcer Plugin
//## 1= Yes
//## 0= No
sm_force_enable "1"

//==========================================================================================

//## How Would You Like To Check Players  
//## 2= By Timer
//## 1= By Change/Join Team
sm_force_mode "2"

//## If [ sm_force_mode 2 ] How Much Time (in sec)
sm_force_timer "0.30"

//## Choose What Type Of Punishment
//## 1= Kick Them From The Server With Message
//## 2= Send Them To Spec With Message
sm_force_method "1"

//## If [ sm_force_method 2 ] How Much Time (in sec) Send Him Messages
sm_force_timer_message "10.0"

//==========================================================================================

//## Only People With cl_allowdownload 1 Enter The Server
//## 1= Yes
//## 0= No
sm_cl_allowdownload "1"

//## Only People With cl_allowupload 1 Enter The Server
//## 1= Yes
//## 0= No
sm_cl_allowupload "0"

//## Only People With cl_downloadfilter all Enter The Server
//## 1= Yes
//## 0= No
sm_cl_downloadfilter "0"

//## Let Linux Users Bypass All CL_Forcer (To Avoid Crashes For Linux Users)
//## 1= Yes
//## 0= No
sm_force_ignorelinux "0"
```


## .:[ Change Log ]:.
```
(1.0.4)
-Fix Bug
-New Syntax
-Added sm_force_enable Enable/Disable Plugin ConVar
-Added sm_force_mode Two Method Checker
-Added sm_force_timer Timer For sm_force_mode Checker
-Added Timer Message sm_force_timer_message If Punishment Was Spec

-Fix sm_force_method Method

(1.0.2)
-Fix Bug
-Added Linux bypass sm_cl_ignorelinux ( prevent crashes L4D2 Linux Clients )

(1.0.1)
-Fix Bug
-Added Force Spec

(1.0.0)
- Initial Release
```


## .:[ Donation ]:.

If this project help you reduce time to develop, you can give me a cup of coffee :)

[![paypal](https://www.paypalobjects.com/en_US/i/btn/btn_donateCC_LG.gif)](https://paypal.me/oQYh)
