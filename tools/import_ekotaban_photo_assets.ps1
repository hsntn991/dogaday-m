param(
  [string]$ZipPath = 'C:\Users\CASPER\Desktop\EKOTABAN_719_FULL_HD_FOTOGRAFLAR.zip'
)

$ErrorActionPreference = 'Stop'
Add-Type -AssemblyName System.IO.Compression.FileSystem

$provinceByCode = @{
  '01' = 'Adana'; '02' = 'Adıyaman'; '03' = 'Afyonkarahisar'; '04' = 'Ağrı'; '05' = 'Amasya';
  '06' = 'Ankara'; '07' = 'Antalya'; '08' = 'Artvin'; '09' = 'Aydın'; '10' = 'Balıkesir';
  '11' = 'Bilecik'; '12' = 'Bingöl'; '13' = 'Bitlis'; '14' = 'Bolu'; '15' = 'Burdur';
  '16' = 'Bursa'; '17' = 'Çanakkale'; '18' = 'Çankırı'; '19' = 'Çorum'; '20' = 'Denizli';
  '21' = 'Diyarbakır'; '22' = 'Edirne'; '23' = 'Elazığ'; '24' = 'Erzincan'; '25' = 'Erzurum';
  '26' = 'Eskişehir'; '27' = 'Gaziantep'; '28' = 'Giresun'; '29' = 'Gümüşhane'; '30' = 'Hakkâri';
  '31' = 'Hatay'; '32' = 'Isparta'; '33' = 'Mersin'; '34' = 'İstanbul'; '35' = 'İzmir';
  '36' = 'Kars'; '37' = 'Kastamonu'; '38' = 'Kayseri'; '39' = 'Kırklareli'; '40' = 'Kırşehir';
  '41' = 'Kocaeli'; '42' = 'Konya'; '43' = 'Kütahya'; '44' = 'Malatya'; '45' = 'Manisa';
  '46' = 'Kahramanmaraş'; '47' = 'Mardin'; '48' = 'Muğla'; '49' = 'Muş'; '50' = 'Nevşehir';
  '51' = 'Niğde'; '52' = 'Ordu'; '53' = 'Rize'; '54' = 'Sakarya'; '55' = 'Samsun';
  '56' = 'Siirt'; '57' = 'Sinop'; '58' = 'Sivas'; '59' = 'Tekirdağ'; '60' = 'Tokat';
  '61' = 'Trabzon'; '62' = 'Tunceli'; '63' = 'Şanlıurfa'; '64' = 'Uşak'; '65' = 'Van';
  '66' = 'Yozgat'; '67' = 'Zonguldak'; '68' = 'Aksaray'; '69' = 'Bayburt'; '70' = 'Karaman';
  '71' = 'Kırıkkale'; '72' = 'Batman'; '73' = 'Şırnak'; '74' = 'Bartın'; '75' = 'Ardahan';
  '76' = 'Iğdır'; '77' = 'Yalova'; '78' = 'Karabük'; '79' = 'Kilis'; '80' = 'Osmaniye'; '81' = 'Düzce'
}

function Get-NormalizedKey([string]$Value) {
  $text = $Value.ToLowerInvariant().Replace('ı', 'i').Replace('İ', 'i').Replace('ş', 's').Replace('Ş', 's').Replace('ğ', 'g').Replace('Ğ', 'g').Replace('ü', 'u').Replace('Ü', 'u').Replace('ö', 'o').Replace('Ö', 'o').Replace('ç', 'c').Replace('Ç', 'c')
  return [regex]::Replace($text, '[^a-z0-9]+', '')
}

$root = Split-Path -Parent $PSScriptRoot
$records = Get-Content (Join-Path $root 'assets\data\turkiye_research_places.json') -Raw | ConvertFrom-Json
$byNameAndProvince = @{}
foreach ($record in $records) {
  $key = "$(Get-NormalizedKey $record.name)|$(Get-NormalizedKey $record.province)"
  if (-not $byNameAndProvince.ContainsKey($key)) {
    $byNameAndProvince[$key] = [System.Collections.Generic.List[object]]::new()
  }
  $byNameAndProvince[$key].Add($record)
}

$assetDirectory = Join-Path $root 'assets\photos\ekotaban'
New-Item -ItemType Directory -Force -Path $assetDirectory | Out-Null
$mapping = [System.Collections.Generic.List[object]]::new()
$archive = [System.IO.Compression.ZipFile]::OpenRead($ZipPath)
try {
  foreach ($entry in $archive.Entries) {
    if ($entry.Length -eq 0 -or $entry.FullName -notmatch '^(\d+)_(\d{2})_.+\.(jpg|jpeg|png)$') { continue }
    $province = $provinceByCode[$Matches[2]]
    if ($null -eq $province) { continue }
    $sourceName = ([IO.Path]::GetFileNameWithoutExtension($entry.Name) -replace '^\d+_\d+_', '') -replace '_', ' '
    $key = "$(Get-NormalizedKey $sourceName)|$(Get-NormalizedKey $province)"
    if (-not $byNameAndProvince.ContainsKey($key) -or $byNameAndProvince[$key].Count -ne 1) { continue }

    $record = $byNameAndProvince[$key][0]
    $extension = [IO.Path]::GetExtension($entry.Name).ToLowerInvariant()
    $assetName = "$($record.id)$extension"
    $destination = Join-Path $assetDirectory $assetName
    [System.IO.Compression.ZipFileExtensions]::ExtractToFile($entry, $destination, $true)
    $mapping.Add([ordered]@{
      id = $record.id
      image_asset = "assets/photos/ekotaban/$assetName"
      source = 'EKOTABAN kullanıcı tarafından sağlanan arşiv'
      source_file = $entry.Name
    })
  }
} finally {
  $archive.Dispose()
}

$mapping | ConvertTo-Json -Depth 3 | Set-Content (Join-Path $root 'assets\data\ekotaban_photo_assets.json') -Encoding utf8
Write-Output "Imported $($mapping.Count) one-to-one photo matches."
