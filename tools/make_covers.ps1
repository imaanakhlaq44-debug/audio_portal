# Converts the cover masters in covers/ into the bundled WebP art in
# assets/covers/.
#
#   powershell -ExecutionPolicy Bypass -File tools\make_covers.ps1
#
# One file per story, shared by its English and Urdu series (both point at the
# same asset in tools/series/*.json). Masters are 1254x1254 PNGs of ~2.4 MB;
# 800x800 WebP keeps the big now-playing cover sharp at ~140 KB each.
#
# After adding a master here, set "cover" in the matching tools/series/*.json
# and rerun tools/gen_series.dart (or edit lib/models/series/*.dart to match).

param([int]$Size = 800, [int]$Quality = 85)

$ErrorActionPreference = 'Stop'
$repo = Resolve-Path (Join-Path $PSScriptRoot '..')
$out = Join-Path $repo 'assets\covers'
New-Item -ItemType Directory -Force $out | Out-Null

# master file name (without .png) -> asset name (without .webp)
$map = [ordered]@{
    'The Beginning of Humanity'   = 'adam'
    'The Golden Balance'          = 'fairness'
    'The Things We Never Notice'  = 'gratitude'
    'The Book of Trust'           = 'honesty'
    'Hazrat Hud (A.S.)'           = 'hud'
    'Hazrat Idris (A.S.)'         = 'idris'
    'Hazrat Nuh (A.S.)'           = 'nuh'
    'Respect and Dignity'         = 'respect'
    'The Kindness That Came Back' = 'kindness'
    'Hazrat Salih (A.S.)'         = 'salih'
    'Things That Take Time'       = 'patience'
}

foreach ($m in $map.GetEnumerator()) {
    $src = Join-Path $repo "covers\$($m.Key).png"
    if (-not (Test-Path $src)) {
        Write-Host "missing master: $($m.Key).png" -ForegroundColor Yellow
        continue
    }
    $dst = Join-Path $out "$($m.Value).webp"
    ffmpeg -y -loglevel error -i $src -vf "scale=${Size}:${Size}:flags=lanczos" -quality $Quality $dst
    if ($LASTEXITCODE -ne 0) { throw "ffmpeg failed on $src" }
    $kb = [math]::Round((Get-Item $dst).Length / 1KB)
    Write-Host ("{0,-10} {1} KB" -f $m.Value, $kb)
}
