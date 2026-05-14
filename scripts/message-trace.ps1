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

$dateStart = $date.AddDays(-1)
$dateEnd = $date

# ==========================================
# EXPORT PATH
# ==========================================

$outputDir = ".\output"

New-Item `
    -ItemType Directory `
    -Path $outputDir `
    -Force | Out-Null

$outputFile = "$outputDir\MessageTrace_$(Get-Date -f yyyyMMdd).csv"

# ==========================================
# GET MESSAGE TRACE
# ==========================================

Get-MessageTraceV2 `
    -StartDate $dateStart `
    -EndDate $dateEnd `
    -ResultSize 5000 |
Export-Csv `
    $outputFile `
    -NoTypeInformation

Write-Host "CSV Exported: $outputFile"

Disconnect-ExchangeOnline `
    -Confirm:$false
