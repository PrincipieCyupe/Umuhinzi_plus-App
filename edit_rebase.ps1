param($file)
$content = Get-Content $file
$content = $content -replace '^pick ea99192', 'drop ea99192'
Set-Content -Path $file -Value $content
