# Copyright 2023 HCL America
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

param($xmlfile);
$aseHostname='<ASE_HOSTNAME>'
$aseApiKeyId='<ASE_API_KEY_ID>'
$aseApiKeySecret='<ASE_API_KEY_SECRET>'

cd reports\
if(Test-Path .\imported\){
	Write-Host "Imported folder exists";
	}
else{
    Write-Host "Folder doesn't exists";
    New-Item imported -ItemType Directory;
	}

write-host "$xmlfile being processed.";
Start-transcript -path .\$xmlfile.log -IncludeInvocationHeader -UseMinimalHeader
[XML]$xml = Get-Content $xmlfile;
$techScan=$xml.'xml-report'.technology
$aseAppName=$xml.'xml-report'.layout.'application-name';
$scanName=$xml.'xml-report'.'scan-information'.'asoc-scan-name';
#$aseAppName=$scanName | select-string -pattern '(.*)...'| % {$_.Matches.Groups[1].Value}

# ASE authentication
$sessionId=$(Invoke-WebRequest -Method "POST" -Headers @{"Accept"="application/json"} -ContentType 'application/json' -Body "{`"keyId`": `"$aseApiKeyId`",`"keySecret`": `"$aseApiKeySecret`"}" -Uri "https://$aseHostname`:9443/ase/api/keylogin/apikeylogin" -SkipCertificateCheck | Select-Object -Expand Content | ConvertFrom-Json | select -ExpandProperty sessionId);
# Looking for $aseAppName into ASE
$session = New-Object Microsoft.PowerShell.Commands.WebRequestSession;
$session.Cookies.Add((New-Object System.Net.Cookie("asc_session_id", "$sessionId", "/", "$aseHostname")));
[int]$aseAppId=$(Invoke-WebRequest -WebSession $session -Headers @{"Asc_xsrf_token"="$sessionId"} -Uri "https://$aseHostname`:9443/ase/api/applications/search?searchTerm=$aseAppName" -SkipCertificateCheck | ConvertFrom-Json).id;
# If $aseAppName is Null create the application into ASE else just get the aseAppId
if ([string]::IsNullOrWhitespace($aseAppId) -or $aseAppId -eq 0){
	$session = New-Object Microsoft.PowerShell.Commands.WebRequestSession;
	$session.Cookies.Add((New-Object System.Net.Cookie("asc_session_id", "$sessionId", "/", "$aseHostname")));
	[int]$aseAppId=$(Invoke-WebRequest -Method POST -WebSession $session -Headers @{"Asc_xsrf_token"="$sessionId"} -ContentType "application/json" -Body "{`"name`":`"$aseAppName`" }" -Uri "https://$aseHostname`:9443/ase/api/applications" -SkipCertificateCheck | ConvertFrom-Json).id;
	write-host "Application $aseAppName registered with id $aseAppId";
	}
else{
	write-host "There is a registered application. Application name is $aseAppName and AppId is $aseAppId";
	}

write-host "The scanName is $scanName and uploadedfile is $xmlfile";
#(Get-Content -path "$xmlfile") | Set-Content -Encoding utf8NoBOM -Path "$xmlfile";
$Form = [ordered]@{
	scanName = $scanName
	uploadedfile = Get-Item -Path $xmlfile
	}

if ($xml.'xml-report'.technology -eq 'SAST'){
	Invoke-WebRequest -Method Post -Form $Form -WebSession $session -Headers @{"Asc_xsrf_token"="$sessionId"}  -Uri "https://$aseHostname`:9443/ase/api/issueimport/$aseAppId/3/" -SkipCertificateCheck | Out-Null;
}
elseif ($xml.'xml-report'.technology -eq 'DAST'){
	Invoke-WebRequest -Method Post -Form $Form -WebSession $session -Headers @{"Asc_xsrf_token"="$sessionId"}  -Uri "https://$aseHostname`:9443/ase/api/issueimport/$aseAppId/16/" -SkipCertificateCheck | Out-Null;
}
	
do{
	$ErrorActionPreference = 'SilentlyContinue';
	$importStatus=(Invoke-WebRequest -WebSession $session -Headers @{"Asc_xsrf_token"="$sessionId"}  -Uri "https://$aseHostname`:9443/ase/api/issueimport/summarylog" -SkipCertificateCheck);
	write-host "Running";
	write-host "$importStatus";
	sleep 5;
}until ($importStatus -match "completed")

move $xmlfile .\imported\;

Invoke-WebRequest -Method GET -WebSession $session -Headers @{"Asc_xsrf_token"="$sessionId";"X-Requested-With"="XMLHttpRequest"}  -Uri "https://$aseHostname`:9443/ase/api/logout" -SkipCertificateCheck | Out-Null;
Stop-transcript
move .\$xmlfile.log .\imported\;
cd imported\
Compress-Archive -Path .\$xmlfile* -DestinationPath .\$xmlfile.zip
remove-item .\$xmlfile
remove-item .\$xmlfile.log
write-host "--------------------------------------------------------------------------------------";
cd ..
cd ..
