# This is a script that monitor the disk usages and shut down the computer if low disk activity is detected.
$threshold = 5000000 # 5MB/sec threshold for "low" disk activity
$lowActivityCounter = 0
$consecutiveLimit = 60
$logFile = "disk_monitor.log"

function Log {
    param([string]$message)
    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    $entry = "$timestamp - $message"
    Write-Host $entry
    Add-Content -Path $logFile -Value $entry
}

Clear-Content -Path $logFile -ErrorAction SilentlyContinue

while ($true) {
    $diskCounter = Get-Counter '\PhysicalDisk(_Total)\Disk Bytes/sec'
    $currentValue = ($diskCounter.CounterSamples | Select-Object -ExpandProperty CookedValue)
    Log "Current Disk Bytes/sec: $currentValue"

    if ($currentValue -lt $threshold) {
        $lowActivityCounter++
        Log "Low disk activity detected! ($lowActivityCounter of $consecutiveLimit)"
    } else {
        $lowActivityCounter = 0
        Log "Disk activity is normal. Counter reset."
    }

    if ($lowActivityCounter -ge $consecutiveLimit) {
        Log "Threshold reached. Initiating shutdown..."
        shutdown.exe /s /t 120 /f
        break
    }

    Start-Sleep -Seconds 1
}
