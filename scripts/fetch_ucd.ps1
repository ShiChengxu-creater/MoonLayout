param([string]$Version = '17.0.0')
$ErrorActionPreference = 'Stop'
$root = Split-Path $PSScriptRoot -Parent
$destination = Join-Path $root 'testdata/ucd'
New-Item -ItemType Directory -Force $destination | Out-Null
$files = @('LineBreak.txt', 'auxiliary/WordBreakProperty.txt',
  'auxiliary/SentenceBreakProperty.txt', 'emoji/emoji-data.txt',
  'extracted/DerivedGeneralCategory.txt', 'EastAsianWidth.txt',
  'auxiliary/LineBreakTest.txt', 'auxiliary/WordBreakTest.txt',
  'auxiliary/SentenceBreakTest.txt')
$records = foreach ($file in $files) {
  $name = Split-Path $file -Leaf
  $path = Join-Path $destination $name
  $url = "https://www.unicode.org/Public/$Version/ucd/$file"
  Invoke-WebRequest -Uri $url -OutFile $path -TimeoutSec 60
  $hash = (Get-FileHash -LiteralPath $path -Algorithm SHA256).Hash.ToLowerInvariant()
  "$hash  $name"
}
[IO.File]::WriteAllText((Join-Path $destination 'SHA256SUMS'), ($records -join "`n") + "`n")
Write-Output "Fetched $($files.Count) Unicode $Version files."
