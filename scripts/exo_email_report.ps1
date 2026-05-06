# ===============================
# STEP 1: Decode Certificate (from GitHub Secret)
# ===============================
$certBase64 = $env:EXO_CERT_BASE64
$certPassword = $env:EXO_CERT_PASSWORD

$certPath = "$env:RUNNER_TEMP\exo_cert.pfx"

[System.IO.File]::WriteAllBytes(
    $certPath,
    [System.Convert]::FromBase64String($certBase64)
)

Write-Host "✅ Certificate file created at $certPath"

# ===============================
# STEP 2: Convert password
# ===============================
$securePassword = ConvertTo-SecureString $certPassword -AsPlainText -Force

# ===============================
# STEP 3: Connect to Exchange Online (NO Thumbprint)
# ===============================
Connect-ExchangeOnline `
    -AppId $env:AZURE_CLIENT_ID `
    -Organization $env:ORG_DOMAIN `
    -CertificateFilePath $certPath `
    -CertificatePassword $securePassword

Write-Host "✅ Connected to Exchange Online"

# ===============================
# STEP 4: Get Last 24 Hours Emails
# ===============================
$end = Get-Date
$start = $end.AddHours(-24)

$emails = Get-MessageTrace `
    -StartDate $start `
    -EndDate $end |
    Where-Object { $_.Direction -eq "Inbound" } |
    Select-Object `
        Received,
        Subject,
        MessageId,
        SenderAddress,
        RecipientAddress,
        Status,
        Size

# ===============================
# STEP 5: Export CSV
# ===============================
$outputFile = "$env:RUNNER_TEMP\InboxEmails_Last24Hours.csv"

$emails | Export-Csv -Path $outputFile -NoTypeInformation -Encoding UTF8

Write-Host "✅ CSV generated at $outputFile"
Write-Host "📊 Total Emails: $($emails.Count)"

# ===============================
# STEP 6: Disconnect
# ===============================
Disconnect-ExchangeOnline -Confirm:$false
