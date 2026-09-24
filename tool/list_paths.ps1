$j = Get-Content d:\REKI\docs.json -Raw | ConvertFrom-Json
$j.paths.PSObject.Properties.Name | Sort-Object | Out-File d:\REKI\tool\paths.txt
$props = @{}
foreach ($p in $j.paths.PSObject.Properties) {
  foreach ($m in $p.Value.PSObject.Properties) {
    $line = ($m.Name.ToUpper() + ' ' + $p.Name)
    $existing = $props[$line]
    $summ = $m.Value.summary
    if ($summ) { $props[$line] = $summ }
  }
}
$props.GetEnumerator() | Sort-Object Name | ForEach-Object { "$($_.Name) :: $($_.Value)" } | Out-File d:\REKI\tool\paths_summary.txt
