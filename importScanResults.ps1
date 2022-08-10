$aseHostname='<ASE_HOSTNAME>'
$aseApiKeyId='<ASE_API_KEY_ID>'
$aseApiKeySecret='<ASE_API_KEY_SECRET>'

cd reports\

if(Test-Path .\imported\){
	Write-Host "Folder Exists";
	}
else{
    Write-Host "Folder Doesn't Exists";
    New-Item imported -ItemType Directory;
	}

$files=$(Get-Item -Path *.xml);
ForEach ($file in $files){
	[XML]$xml = Get-Content $file;
	$aseAppName=$xml.'xml-report'.layout.'application-name';
	$scanName=$xml.'xml-report'.'scan-information'.'scan-name';

	# ASE authentication
	$sessionId=$(Invoke-WebRequest -Method "POST" -Headers @{"Accept"="application/json"} -ContentType 'application/json' -Body "{`"keyId`": `"$aseApiKeyId`",`"keySecret`": `"$aseApiKeySecret`"}" -Uri "https://$aseHostname`:9443/ase/api/keylogin/apikeylogin" -SkipCertificateCheck | Select-Object -Expand Content | ConvertFrom-Json | select -ExpandProperty sessionId);
	# Looking for $aseAppName into ASE
	$session = New-Object Microsoft.PowerShell.Commands.WebRequestSession;
	$session.Cookies.Add((New-Object System.Net.Cookie("asc_session_id", "$sessionId", "/", "$aseHostname")));
	$aseAppId=$(Invoke-WebRequest -WebSession $session -Headers @{"Asc_xsrf_token"="$sessionId"} -Uri "https://$aseHostname`:9443/ase/api/applications/search?searchTerm=$aseAppName" -SkipCertificateCheck | ConvertFrom-Json).id;
	# If $aseAppName is Null create the application into ASE else just get the aseAppId
	if ([string]::IsNullOrWhitespace($aseAppId)){
		$session = New-Object Microsoft.PowerShell.Commands.WebRequestSession;
		$session.Cookies.Add((New-Object System.Net.Cookie("asc_session_id", "$sessionId", "/", "$aseHostname")));
		$aseAppId=$(Invoke-WebRequest -Method POST -WebSession $session -Headers @{"Asc_xsrf_token"="$sessionId"} -ContentType "application/json" -Body "{`"name`":`"$aseAppName`" }" -Uri "https://$aseHostname`:9443/ase/api/applications" -SkipCertificateCheck | ConvertFrom-Json).id;
		write-host "Application $aseAppName registered with id $aseAppId";
		sleep 10;
		}
	else{
		write-host "There is a registered application. aseAppId $aseAppId";
		}

	sleep 10	
	Invoke-WebRequest -Method Post -Form @{"scanName"="$scanName";"uploadedfile"=$file} -WebSession $session -Headers @{"Asc_xsrf_token"="$sessionId";"X-Requested-With"="XMLHttpRequest"}  -Uri "https://$aseHostname`:9443/ase/api/issueimport/$aseAppId/3/" -SkipCertificateCheck | Out-Null;

	move $file .\imported\;
	write-host "File imported $file, scanName is $scanName";
	write-host "--------------------------------------------------------------------------------------";
	sleep 10;
}

Invoke-WebRequest -Method GET -WebSession $session -Headers @{"Asc_xsrf_token"="$sessionId";"X-Requested-With"="XMLHttpRequest"}  -Uri "https://$aseHostname`:9443/ase/api/logout" -SkipCertificateCheck | Out-Null;

cd ..
