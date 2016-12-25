# Server config

enable-psRemoting -force
# Notice: make sure you wanna trust every host.
Set-Item wsman:\localhost\client\trustedhosts *

Restart-Service WinRM
Set-PSSessionConfiguration -ShowSecurityDescriptorUI -Name Microsoft.PowerShell

#Client config
# if not able to connect server, try entering "enable-psRemoting -force"

$password = ConvertTo-SecureString "password" -AsPlainText -Force
$cred= New-Object System.Management.Automation.PSCredential ("account", $password )
Enter-PSSession -ComputerName "serverName" -Credential $cred

# using domain user
$cred= New-Object System.Management.Automation.PSCredential ("account@domain", $password )
# or local user
$cred= New-Object System.Management.Automation.PSCredential ("serverName\account", $password )

# connect into ...
# Enter-PSSession -ComputerName "serverName" -Credential $cred

# Only remote command
Invoke-Command -ComputerName "serverName" -credential $cred -ScriptBlock {
	cd "C:\yourRepository"
	git pull
}