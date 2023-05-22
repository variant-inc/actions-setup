Get-ChildItem env:SECRET__* | ForEach-Object {
  $name = $_.Name -replace "SECRET__", ""
  Add-Content -Path ${env:GITHUB_ENV} `
    -Encoding utf8 `
    -Value "$name=$($_.Value)"
}
