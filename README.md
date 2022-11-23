## Automation Import Scan Issues from ASOC to ASE

![image](https://user-images.githubusercontent.com/69405400/183989000-647f4ad5-d1d8-4c5e-bd46-4dec0dfc7527.png)


## Requirements
1 - AppScan Enterprise Server hostname<br>
2 - AppScan Enterprise key pair<br>
3 - AppScan Presence (ASoC)<br>
4 - Python3 for Windows (Flask and requests)<br>
5 - Powershell 7.x<br>
<br>
Install Python modules<br>
```
py -m pip install Flask
py -m pip install requests
```
<br>
Change variable in the file below:<br>
startWebHookProxy.ps1:<br>
$asocApiKeyId='aaaaaaaaaaaaaaaaaaaaaaaaa'
$asocApiKeySecret='aaaaaaaaaaaaaaaaaaaaaaaaa'
$presenceId='aaaaaaaaaaaaaaaaaaaaaaaaa'
$aseHostname='aaaaaaaaaaaaaaaaaaaaaaaaa'
$aseApiKeyId='aaaaaaaaaaaaaaaaaaaaaaaaa'
$aseApiKeySecret='aaaaaaaaaaaaaaaaaaaaaaaaa'
<br>
After download this project, install all requirements, add the variables and you are ready to run the automation. Just run .\startWebHookProxy.ps1. <br>
PS: AppScan Presence will connect ASoC and webhookproxy local service. It needs to be up and running at all time.
