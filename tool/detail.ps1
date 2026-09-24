$j = Get-Content d:\REKI\docs.json -Raw | ConvertFrom-Json
$targets = @('/offers/{id}/claim','/offers/{id}/redeem','/business/venues/{id}/status','/venues','/venues/map-markers','/venues/trending','/config/app')
foreach ($t in $targets) {
  $p = $j.paths.$t
  if ($null -ne $p) { ($t + ' => ' + ($p | ConvertTo-Json -Depth 8 -Compress)) | Out-File -Append d:\REKI\tool\detail.txt }
  else { ($t + ' => MISSING') | Out-File -Append d:\REKI\tool\detail.txt }
}
