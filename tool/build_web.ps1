param(
    [Parameter(ValueFromRemainingArguments = $true)]
    [string[]]$FlutterArguments
)

$ErrorActionPreference = 'Stop'
$projectRoot = Split-Path -Parent $PSScriptRoot
$associationSource = Join-Path $projectRoot 'web\.well-known'
$associationOutput = Join-Path $projectRoot 'build\web\.well-known'

Push-Location $projectRoot
try {
    & flutter build web @FlutterArguments
    if ($LASTEXITCODE -ne 0) {
        throw "Flutter web build failed with exit code $LASTEXITCODE."
    }

    New-Item -ItemType Directory -Path $associationOutput -Force | Out-Null
    Copy-Item -Path (Join-Path $associationSource '*') `
        -Destination $associationOutput -Force

    Write-Host 'Web build complete. App-link association files copied to:'
    Write-Host "  $associationOutput"
} finally {
    Pop-Location
}
