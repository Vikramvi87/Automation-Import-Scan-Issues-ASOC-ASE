import subprocess, sys, time

def handle(webhookObj, data):
    p = subprocess.Popen(["pwsh.exe","-File","importScanResults.ps1"],stdout=sys.stdout)
    p.communicate()
    time.sleep(10)