<#
.SYNOPSIS
Split one long series recording into per-story mp3 files.

.DESCRIPTION
Two passes, so a cut never lands somewhere you did not look at:

  detect  Find the silent gaps between stories and write a plan file listing
          every proposed segment with its start, end and length. Open the
          plan, delete rows that are not real story breaks, and type the real
          story id for each row you keep.

  split   Cut the source at exactly those points. The audio is copied, not
          re-encoded, so there is no quality loss and a 30 minute file splits
          in seconds.

Requires ffmpeg on PATH:  winget install Gyan.FFmpeg

.EXAMPLE
  .\tools\split_series.ps1 detect "E:\raw\series1.mp3"
  .\tools\split_series.ps1 detect "E:\raw\series1.mp3" -MinSilence 1.5 -Noise "-32dB"
  .\tools\split_series.ps1 split  "E:\raw\series1.mp3"
#>
param(
    [Parameter(Mandatory = $true, Position = 0)]
    [ValidateSet('detect', 'split')]
    [string]$Command,

    [Parameter(Mandatory = $true, Position = 1)]
    [string]$Source,

    # A gap at least this long (seconds) counts as a break between stories.
    [double]$MinSilence = 1.2,

    # Ignore segments shorter than this - almost always a stray pause.
    [double]$MinStory = 30,

    # Anything quieter than this counts as silence.
    [string]$Noise = '-35dB',

    [string]$OutDir = 'assets/audio'
)

$ErrorActionPreference = 'Stop'

# Audio is copied, not re-encoded, so a cut can only land on a frame boundary.
# Keeping a little of the silence on each side hides that rounding.
$Pad = 0.25

function Assert-Ffmpeg {
    foreach ($exe in 'ffmpeg', 'ffprobe') {
        if (-not (Get-Command $exe -ErrorAction SilentlyContinue)) {
            throw "$exe not found on PATH. Install it once with 'winget install Gyan.FFmpeg', then open a new terminal."
        }
    }
}

function Format-Time([double]$Seconds) {
    '{0:d2}:{1:00.00}' -f [int][math]::Floor($Seconds / 60), ($Seconds % 60)
}

function Get-PlanPath([string]$Path) {
    Join-Path (Split-Path -Parent (Resolve-Path $Path)) ((Get-Item $Path).BaseName + '.plan.json')
}

function Invoke-Detect {
    $total = [double](& ffprobe -v error -show_entries format=duration -of csv=p=0 $Source)

    # silencedetect reports on stderr; capture it as text.
    $log = & ffmpeg -hide_banner -nostats -i $Source -af "silencedetect=noise=$Noise`:d=$MinSilence" -f null - 2>&1 |
        Out-String

    $starts = [regex]::Matches($log, 'silence_start: (-?[\d.]+)') | ForEach-Object { [double]$_.Groups[1].Value }
    $ends = [regex]::Matches($log, 'silence_end: (-?[\d.]+)') | ForEach-Object { [double]$_.Groups[1].Value }

    # Cut in the middle of each silent gap; that becomes one story boundary.
    $cuts = @()
    for ($i = 0; $i -lt [math]::Min($starts.Count, $ends.Count); $i++) {
        if (($ends[$i] - $starts[$i]) -ge $MinSilence) {
            $cuts += ($starts[$i] + $ends[$i]) / 2
        }
    }

    $bounds = @(0.0) + $cuts + @($total)
    $segments = @()
    for ($i = 0; $i -lt $bounds.Count - 1; $i++) {
        $start = $bounds[$i]
        $end = $bounds[$i + 1]
        if (($end - $start) -lt $MinStory) { continue }
        $segments += [pscustomobject]@{
            id    = "story_$($segments.Count + 1)"
            start = [math]::Round(($(if ($i -eq 0) { 0.0 } else { [math]::Max(0.0, $start - $Pad) })), 2)
            end   = [math]::Round([math]::Min($total, $end + $Pad), 2)
        }
    }

    $planPath = Get-PlanPath $Source
    [pscustomobject]@{ source = (Resolve-Path $Source).Path; segments = $segments } |
        ConvertTo-Json -Depth 5 | Out-File -FilePath $planPath -Encoding utf8

    Write-Host ""
    Write-Host "$(Split-Path -Leaf $Source)  -  $(Format-Time $total) total, $($starts.Count) silent gaps, $($segments.Count) segments"
    Write-Host ""
    foreach ($s in $segments) {
        $len = $s.end - $s.start
        Write-Host ("  {0,-12} {1} -> {2}   ({3})" -f $s.id, (Format-Time $s.start), (Format-Time $s.end), (Format-Time $len))
    }
    Write-Host ""
    Write-Host "Plan written to $planPath"
    Write-Host "Edit it (rename each id, delete non-story rows), then run:"
    Write-Host "  .\tools\split_series.ps1 split `"$Source`""
}

function Invoke-Split {
    $planPath = Get-PlanPath $Source
    if (-not (Test-Path $planPath)) {
        throw "No plan found at $planPath. Run 'detect' first."
    }

    $plan = Get-Content $planPath -Raw | ConvertFrom-Json
    if (-not (Test-Path $OutDir)) { New-Item -ItemType Directory -Path $OutDir | Out-Null }

    foreach ($seg in $plan.segments) {
        $dest = Join-Path $OutDir "$($seg.id).mp3"
        & ffmpeg -hide_banner -loglevel error -y -ss $seg.start -to $seg.end -i $Source -c copy $dest
        $sizeKb = (Get-Item $dest).Length / 1KB
        Write-Host ("  wrote {0}  ({1}, {2:n0} KB)" -f $dest, (Format-Time ($seg.end - $seg.start)), $sizeKb)
    }

    Write-Host ""
    Write-Host "$($plan.segments.Count) files written to $OutDir/"
    Write-Host "Next: add a Story entry for each one in lib/models/story_data.dart"
}

Assert-Ffmpeg
switch ($Command) {
    'detect' { Invoke-Detect }
    'split' { Invoke-Split }
}
