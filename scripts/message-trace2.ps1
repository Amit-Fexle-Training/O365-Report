Import-Module ExchangeOnlineManagement

# ==========================================
# VARIABLES
# ==========================================

$appId = $env:EXO_APP_ID
$organization = $env:EXO_TENANT
$pfxPassword = ConvertTo-SecureString `
    $env:EXO_PFX_PASSWORD `
    -AsPlainText `
    -Force

$certPath = "$env:RUNNER_TEMP\exo_cert.pfx"

# ==========================================
# CONNECT
# ==========================================

Connect-ExchangeOnline `
    -CertificateFilePath $certPath `
    -CertificatePassword $pfxPassword `
    -AppId $appId `
    -Organization $organization `
    -ShowBanner:$false

# ==========================================
# DATE RANGE
# ==========================================

$date = Get-Date

$dateStart = $date.AddDays(-10)
$dateEnd = $date

# ==========================================
# EXPORT PATH
# ==========================================

$outputDir = ".\output"

$recipientList = @(
    "admin01@74wx1q.onmicrosoft.com"
)

New-Item `
    -ItemType Directory `
    -Path $outputDir `
    -Force | Out-Null

$outputFile = "$outputDir\MessageTrace_$(Get-Date -f yyyyMMdd).csv"

# ==========================================
# PROCESS EACH MAILBOX
# ==========================================

foreach ($recipient in $recipientList) {

    Write-Host "Processing mailbox: $recipient"

    $safeName = $recipient.Replace("@", "_").Replace(".", "_")

    $outputFile = Join-Path `
        $outputDir `
        "${safeName}_$(Get-Date -f yyyyMMdd).csv"

    Get-MessageTraceV2 `
        -RecipientAddress $recipient `
        -StartDate $dateStart `
        -EndDate $dateEnd `
        -ResultSize 5000 |
    Export-Csv `
        -Path $outputFile `
        -NoTypeInformation `
        -Encoding UTF8

    Write-Host "CSV Exported: $outputFile"
}

# ==========================================
# DISCONNECT
# ==========================================

Disconnect-ExchangeOnline `
    -Confirm:$false

Write-Host "Disconnected from Exchange Online"
