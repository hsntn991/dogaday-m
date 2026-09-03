param(
  [Parameter(Mandatory = $true)][string]$InputJson,
  [Parameter(Mandatory = $true)][string]$OutputJson
)

$records = Get-Content -LiteralPath $InputJson -Raw | ConvertFrom-Json
if ($records -isnot [array] -and $null -ne $records.places) {
  $records = $records.places
}

$compact = foreach ($place in $records) {
  $hasAbout = -not [string]::IsNullOrWhiteSpace($place.about_text)
  $hasAmenities = $null -ne $place.app_amenities -and $place.app_amenities.Count -gt 0
  $hasPhotos = $null -ne $place.photos -and $place.photos.Count -gt 0
  if (-not ($hasAbout -or $hasAmenities -or $hasPhotos)) { continue }

  [ordered]@{
    name = $place.name
    latitude = $place.latitude
    longitude = $place.longitude
    about_text = $place.about_text
    about_sources = @($place.about_sources)
    amenities_status = $place.amenities_status
    app_amenities = @($place.app_amenities)
    photos = @($place.photos)
  }
}

$parent = Split-Path -Parent $OutputJson
New-Item -ItemType Directory -Path $parent -Force | Out-Null
$compact | ConvertTo-Json -Depth 12 -Compress | Set-Content -LiteralPath $OutputJson -Encoding utf8NoBOM
Write-Output "Enrichment asset: $($compact.Count) records"
