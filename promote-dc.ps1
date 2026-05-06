$DSRMPassword = Read-Host -AsSecureString -Prompt "Enter DSRM password"

Install-ADDSForest -DomainName "contoso.local" -DomainNetbiosName "CONTOSO" -ForestMode "WinThreshold" -DomainMode "WinThreshold" -InstallDns:$true -DatabasePath "C:\Windows\NTDS" -LogPath "C:\Windows\NTDS" -SysvolPath "C:\Windows\SYSVOL" -SafeModeAdministratorPassword $DSRMPassword -Force:$true