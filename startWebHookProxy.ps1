do{
	$env:FLASK_ENV='development'
	$env:FLASK_APP='asoc_webhook_proxy'
	$proc = Start-Process py -ArgumentList ' -m flask run --host=0.0.0.0 --port=5000 --no-reload' -PassThru -NoNewWindow
	Start-Sleep -seconds 3600
	$proc | Stop-Process
}while ($true)