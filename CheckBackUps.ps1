$Yesterday = (get-date (get-date).addDays(-1) -UFormat "%Y%m%d")

$arrServers = "Server1", "Server2"

echo "`n`n`n" #make some room

foreach ($server in $arrServers) {
  echo "querying the shit out of $server"
  $BackUpCheck = Get-WmiObject -Namespace "root\cimv2" -Class Win32_NTLogEvent -Impersonation 3 -ComputerName $server -filter "(logfile='Application' AND SourceName='Microsoft-Windows-Backup' AND TimeWritten >= '$Yesterday')"

  $CurrentValues = $BackUpCheck.Type.Count

  if ($CurrentValues -eq 0) {
      # run Symantec System Recovery query
      $SSR = "1"
      echo "  - Looks like this one is running Symantec System Recovery, modifying query..."
      $BackUpCheck = Get-WmiObject -Namespace "root\cimv2" -Class Win32_NTLogEvent -Impersonation 3 -ComputerName $server -filter "(logfile='Application' AND SourceName='Symantec System Recovery' AND TimeWritten >= '$Yesterday')"
  } else {
    $SSR = "0"
  }

  foreach ($LogEntries in $BackUpCheck) {
    if ($LogEntries.Type -eq "Information") {
        $backup_error = "0"
    } else {
        $backup_error = "1"
        $BackUpCheckMessage = $LogEntries.Message
        break
    }
  }
  
  if ($backup_error -eq "1") {
    echo "Holy fuck there's an error guy! $BackUpCheckMessage"
  } else {
    echo "Successful Backup."
  }

  echo "`n`n"
}
