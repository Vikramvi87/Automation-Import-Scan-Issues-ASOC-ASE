## Automation Import Scan Issues from ASOC to ASE

![image](https://user-images.githubusercontent.com/69405400/183989000-647f4ad5-d1d8-4c5e-bd46-4dec0dfc7527.png)


## Requirements
1 - AppScan Enterprise Server hostname<br>
2 - AppScan Enterprise key pair<br>
3 - AppScan Presence (ASoC)
4 - Python3 for Windows (Flask and requests)<br>
5 - Powershell 7.x<br>
<br>
Install Python modules<br>
```
py -m pip install Flask
py -m pip install requests
```
<br>
Change variables in the files below:<br>
Config.json:<br>
-> HOSTNAME Where is running this service<br>
-> ASOC_API_KEY_ID<br>
-> ASOC_API_KEY_SECRET<br>
-> APPSCAN_PRESENCE_ID<br>

<br>
importScanResults.ps1:<br>
-> ASE_HOSTNAME<br>
-> ASE_API_KEY_ID<br>
-> ASE_API_KEY_SECRET<br>
<br>
After download this project, install all requirements, add the variables you are ready to run the automation. First of all, execute appscan presence, open pwsh.exe and run .\startWebHookProxy.ps1. <br>
PS: AppScan Presence will connect ASoC and webhookproxy local service. It needs to be up and running at all times.
