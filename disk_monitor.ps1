# This is a script that monitor the disk usages and shut down the computer if low disk activity is detected.
$threshold = 5000000 # 5MB/sec threshold for "low" disk activity
$diskTimeThreshold = 1 # 1% Disk Time threshold
$lowActivityCounter = 0
$consecutiveLimit = 10
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
    $counters = Get-Counter -Counter '\PhysicalDisk(_Total)\Disk Bytes/sec', '\PhysicalDisk(_Total)\% Disk Time'
    $bytesPerSec = ($counters.CounterSamples | Where-Object {$_.Path -like "*Disk Bytes/sec"}).CookedValue
    $diskTime = ($counters.CounterSamples | Where-Object {$_.Path -like "*% Disk Time"}).CookedValue

    Log "Current Disk Bytes/sec: $bytesPerSec"
    Log "Current % Disk Time: $diskTime"

    if ($bytesPerSec -lt $threshold -and $diskTime -le $diskTimeThreshold) {
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

