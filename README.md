## Automation Import Scan Issues from ASOC to ASE

![image](https://user-images.githubusercontent.com/69405400/183989000-647f4ad5-d1d8-4c5e-bd46-4dec0dfc7527.png)


## Requirements
1 - AppScan Enterprise Server hostname<br>
2 - AppScan Enterprise key pair<br>
3 - Python3 for Windows (Flask and requests)<br>
4 - Powershell 7.x<br>
<br>
Install Python modules<br>
```
py -m pip install Flask
py -m pip install requests
```
<br>
Change variables in the files below:<br>
  Config.json:<br>
```
HOSTNAME
ASOC_API_KEY_ID>
ASOC_API_KEY_SECRET
APPSCAN_PRESENCE_ID
```
<br>
  importScanResults.ps1:<br>
```
ASE_HOSTNAME
ASE_API_KEY_ID
ASE_API_KEY_SECRET
    ```
