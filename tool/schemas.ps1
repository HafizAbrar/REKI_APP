$j = Get-Content d:\REKI\docs.json -Raw | ConvertFrom-Json
$names = $j.components.schemas.PSObject.Properties.Name
foreach ($n in $names) {
  if ($n -match 'Redeem|VenueStatus|Claim|WhatOn|Announcement|LiveUpdate') {
    ($n + ' => ' + ($j.components.schemas.$n | ConvertTo-Json -Depth 6 -Compress)) | Out-File -Append d:\REKI\tool\schemas.txt
  }
}
