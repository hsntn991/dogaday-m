param(
  [string]$SourceDirectory = (Join-Path $PSScriptRoot '..\assets\photos\ekotaban'),
  [string]$OutputDirectory = (Join-Path $PSScriptRoot '..\assets\photos\ekotaban_optimized'),
  [int]$MaxLongEdge = 1600,
  [long]$JpegQuality = 85
)

$ErrorActionPreference = 'Stop'
Add-Type -AssemblyName System.Drawing

function Get-JpegCodec {
  [System.Drawing.Imaging.ImageCodecInfo]::GetImageEncoders() |
    Where-Object { $_.MimeType -eq 'image/jpeg' } |
    Select-Object -First 1
}

if (-not (Test-Path -LiteralPath $SourceDirectory)) {
  throw "Kaynak klasör bulunamadı: $SourceDirectory"
}

New-Item -ItemType Directory -Force -Path $OutputDirectory | Out-Null
$codec = Get-JpegCodec
$encoderParameters = New-Object System.Drawing.Imaging.EncoderParameters 1
$encoderParameters.Param[0] = New-Object System.Drawing.Imaging.EncoderParameter(
  [System.Drawing.Imaging.Encoder]::Quality,
  $JpegQuality
)

$sourceFiles = Get-ChildItem -LiteralPath $SourceDirectory -File -Filter '*.jpg'
foreach ($source in $sourceFiles) {
  $destination = Join-Path $OutputDirectory $source.Name
  $image = [System.Drawing.Image]::FromFile($source.FullName)
  try {
    $longEdge = [Math]::Max($image.Width, $image.Height)
    $scale = if ($longEdge -gt $MaxLongEdge) { $MaxLongEdge / [double]$longEdge } else { 1.0 }
    $width = [Math]::Max(1, [int][Math]::Round($image.Width * $scale))
    $height = [Math]::Max(1, [int][Math]::Round($image.Height * $scale))
    $bitmap = New-Object System.Drawing.Bitmap $width, $height
    try {
      $graphics = [System.Drawing.Graphics]::FromImage($bitmap)
      try {
        $graphics.CompositingQuality = [System.Drawing.Drawing2D.CompositingQuality]::HighQuality
        $graphics.InterpolationMode = [System.Drawing.Drawing2D.InterpolationMode]::HighQualityBicubic
        $graphics.SmoothingMode = [System.Drawing.Drawing2D.SmoothingMode]::HighQuality
        $graphics.DrawImage($image, 0, 0, $width, $height)
      }
      finally { $graphics.Dispose() }
      $bitmap.Save($destination, $codec, $encoderParameters)
    }
    finally { $bitmap.Dispose() }
  }
  finally { $image.Dispose() }
}

$sourceBytes = ($sourceFiles | Measure-Object -Property Length -Sum).Sum
$optimizedFiles = Get-ChildItem -LiteralPath $OutputDirectory -File -Filter '*.jpg'
$optimizedBytes = ($optimizedFiles | Measure-Object -Property Length -Sum).Sum
[pscustomobject]@{
  files = $optimizedFiles.Count
  source_mb = [Math]::Round($sourceBytes / 1MB, 2)
  optimized_mb = [Math]::Round($optimizedBytes / 1MB, 2)
  saved_percent = [Math]::Round((1 - ($optimizedBytes / $sourceBytes)) * 100, 1)
} | ConvertTo-Json
