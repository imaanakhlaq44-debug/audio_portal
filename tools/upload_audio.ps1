# Uploads assets/audio/ to the Cloudflare R2 bucket that serves story audio.
#
# Object keys mirror the folder layout (assets/audio/en/fairness/01_x.ogg ->
# en/fairness/01_x.ogg), which is what Story.audioUrl expects.
#
# Uses Cloudflare's wrangler CLI through npx, so no API keys are stored: the
# first run opens a browser to log in to Cloudflare.
#
#   powershell -ExecutionPolicy Bypass -File tools\upload_audio.ps1            # upload everything
#   powershell -ExecutionPolicy Bypass -File tools\upload_audio.ps1 -Only en/fairness
#   powershell -ExecutionPolicy Bypass -File tools\upload_audio.ps1 -DryRun
#
# Devices cache audio by file name. To replace a recording, upload it under a
# NEW name and point the series at it; overwriting keeps old copies on phones.

param(
    [string]$Bucket = 'qissora-audio',
    [string]$BaseUrl = 'https://audio.qissora.app',
    # Only upload keys starting with this prefix, e.g. 'ur/adam'.
    [string]$Only = '',
    # Cloudflare account that owns the bucket (the id in the dashboard URL,
    # dash.cloudflare.com/<id>). Needed when the login can see several
    # accounts; otherwise wrangler may pick one without R2.
    [string]$AccountId = '',
    [switch]$DryRun
)

$ErrorActionPreference = 'Stop'
$root = Resolve-Path (Join-Path $PSScriptRoot '..\assets\audio')

$types = @{
    '.ogg' = 'audio/ogg'
    '.opus' = 'audio/ogg'
    '.mp3' = 'audio/mpeg'
    '.m4a' = 'audio/mp4'
    '.aac' = 'audio/aac'
    '.wav' = 'audio/wav'
}

$files = Get-ChildItem $root -Recurse -File |
    Where-Object { $types.ContainsKey($_.Extension.ToLower()) } |
    ForEach-Object {
        [pscustomobject]@{
            File = $_
            Key  = $_.FullName.Substring($root.Path.Length + 1).Replace('\', '/')
        }
    } |
    Where-Object { $_.Key.StartsWith($Only) } |
    Sort-Object Key

if (-not $files) { throw "No audio files found under $root matching '$Only'." }

$totalMb = [math]::Round(($files.File | Measure-Object Length -Sum).Sum / 1MB, 1)
Write-Host "$($files.Count) files, $totalMb MB -> r2://$Bucket" -ForegroundColor Cyan

if ($AccountId) { $env:CLOUDFLARE_ACCOUNT_ID = $AccountId }

if (-not $DryRun) {
    # Log in up front (no-op when already logged in) so the loop isn't
    # interrupted by a browser prompt, and show which account is in use.
    # whoami exits 0 even when logged out, so check its output instead.
    $who = npx --yes wrangler whoami 2>&1 | Out-String
    if ($who -match 'not authenticated') {
        npx --yes wrangler login
        if ($LASTEXITCODE -ne 0) { throw 'Cloudflare login failed.' }
        $who = npx --yes wrangler whoami 2>&1 | Out-String
    }
    Write-Host $who
}

$failed = @()
$i = 0
foreach ($f in $files) {
    $i++
    $type = $types[$f.File.Extension.ToLower()]
    Write-Host ("[{0}/{1}] {2}" -f $i, $files.Count, $f.Key)
    if ($DryRun) { continue }

    npx --yes wrangler r2 object put "$Bucket/$($f.Key)" `
        --file "$($f.File.FullName)" `
        --content-type $type `
        --cache-control 'public, max-age=604800' `
        --remote | Out-Null
    if ($LASTEXITCODE -ne 0) {
        Write-Host "  failed" -ForegroundColor Red
        $failed += $f.Key
        # A failing first upload is a login/account/bucket problem, not a
        # file problem; stop instead of repeating the same error 144 times.
        if ($i -eq 1) {
            Write-Host "`nStopping: check the account and bucket above (wrangler whoami), or pass -AccountId." -ForegroundColor Red
            exit 1
        }
    }
}

if ($DryRun) { Write-Host 'Dry run: nothing uploaded.' -ForegroundColor Yellow; exit 0 }

if ($failed) {
    Write-Host "`n$($failed.Count) upload(s) failed:" -ForegroundColor Red
    $failed | ForEach-Object { Write-Host "  $_" }
    Write-Host "Re-run with -Only <prefix> to retry." -ForegroundColor Red
    exit 1
}

# Spot-check that the first file is actually reachable through the domain.
$check = "$BaseUrl/$($files[0].Key)"
try {
    $res = Invoke-WebRequest $check -Method Head -UseBasicParsing
    Write-Host "`nDone. $check -> $($res.StatusCode) $($res.Headers['Content-Type'])" -ForegroundColor Green
} catch {
    Write-Host "`nUploaded, but $check is not reachable yet: $_" -ForegroundColor Yellow
}
