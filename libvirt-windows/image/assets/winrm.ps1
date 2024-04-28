winrm quickconfig -q
winrm quickconfig -transport:HTTP

Get-NetConnectionProfile | Set-NetConnectionProfile -NetworkCategory Private

Enable-PSRemoting -Force

winrm quickconfig -q
winrm quickconfig -transport:http

winrm set winrm/config '@{MaxTimeoutms="1800000"}'
winrm set winrm/config/winrs '@{MaxMemoryPerShellMB="800"}'
winrm set winrm/config/service '@{AllowUnencrypted="true"}'
winrm set winrm/config/service/auth '@{Basic="true"}'
winrm set winrm/config/client/auth '@{Basic="true"}'
winrm set winrm/config/listener?Address=*+Transport=HTTP '@{Port="5985"}'

Set-NetFirewallProfile -Profile Domain -Enabled False
Set-NetFirewallProfile -Profile Public -Enabled False
Set-NetFirewallProfile -Profile Private -Enabled False

netsh advfirewall firewall set rule group="Windows Remote Administration" new enable=yes
netsh advfirewall firewall set rule name="Windows Remote Management (HTTP-In)" new enable=yes action=allow remoteip=any

Set-Service winrm -startuptype "auto"
Restart-Service winrm