Add-Type -AssemblyName System.IO.Ports
Add-Type -AssemblyName System.Windows.Forms

function Get-NmeaDataFromComPort {
    param (
        [string]$comPort,
        [int]$baudRate = 9600
    )
    
    $port = $null
    try {
        $port = New-Object System.IO.Ports.SerialPort $comPort, $baudRate, None, 8, One
        $port.Open()
        $port.ReadTimeout = 500 # Reduced timeout to match refresh rate
        
        $gpsInfo = @{
            Latitude = $null
            Longitude = $null
            Altitude = $null
            Speed = $null
            Time = $null
            Satellites = $null
        }
        
        while ($true) {
            try {
                $data = $port.ReadLine().Trim()
                
                # Parse common NMEA sentences
                if ($data -match '^\$GPGGA') {
                    $parts = $data -split ','
                    if ($parts.Length -ge 10) {
                        # Time
                        if ($parts[1]) {
                            $timeStr = $parts[1]
                            $gpsInfo.Time = "{0}:{1}:{2}" -f $timeStr.Substring(0,2), $timeStr.Substring(2,2), $timeStr.Substring(4,2)
                        }
                        
                        # Latitude
                        if ($parts[2] -and $parts[3]) {
                            $lat = [double]::Parse($parts[2]) / 100
                            $latDir = $parts[3]
                            $gpsInfo.Latitude = "{0:F4} {1}" -f $lat, $latDir
                        }
                        
                        # Longitude
                        if ($parts[4] -and $parts[5]) {
                            $long = [double]::Parse($parts[4]) / 100
                            $longDir = $parts[5]
                            $gpsInfo.Longitude = "{0:F4} {1}" -f $long, $longDir
                        }
                        
                        # Satellites
                        $gpsInfo.Satellites = $parts[7]
                    }
                }
                elseif ($data -match '^\$GPRMC') {
                    $parts = $data -split ','
                    if ($parts.Length -ge 9) {
                        # Speed
                        if ($parts[7]) {
                            $gpsInfo.Speed = "{0:F2} knots" -f [double]::Parse($parts[7])
                        }
                        
                        # Altitude (not directly in RMC sentence, using GGA for this)
                        if ($parts[8]) {
                            $gpsInfo.Altitude = "{0:F2} m" -f [double]::Parse($parts[8])
                        }
                    }
                }
                
                # Return both raw data and parsed info
                return @{
                    RawData = $data
                    ParsedInfo = $gpsInfo
                }
            }
            catch {
                # Timeout or read error, continue with what we have
                return @{ RawData = "No data"; ParsedInfo = $gpsInfo }
            }
        }
    }
    catch {
        Write-Host "Error accessing $comPort : $_" -ForegroundColor Red
        return $null
    }
    finally {
        if ($port -and $port.IsOpen) {
            $port.Close()
        }
    }
}

function AutoSelectGpsPort {
    $comPorts = [System.IO.Ports.SerialPort]::GetPortNames()
    foreach ($port in $comPorts) {
        try {
            $testPort = New-Object System.IO.Ports.SerialPort $port, 9600, None, 8, One
            $testPort.Open()
            $testPort.Close()
            $gpsData = Get-NmeaDataFromComPort -comPort $port
            if ($gpsData.RawData -match '^\$G') {
                return $port
            }
        }
        catch {
            # If we can't open the port or read from it, it's not likely GPS
        }
    }
    return $null
}

function Start-GpsMonitor {
    param (
        [string]$comPort
    )

    # Clear console
    Clear-Host

    # Prepare console buffer
    $host.UI.RawUI.BufferSize = New-Object System.Management.Automation.Host.Size(200, 3000)
    $host.UI.RawUI.WindowSize = New-Object System.Management.Automation.Host.Size(200, 50)

    # Tracking data
    $rawDataBuffer = New-Object System.Collections.ArrayList
    $maxRawDataLines = 10

    # List of COM ports at the top
    $comPorts = [System.IO.Ports.SerialPort]::GetPortNames()
    Write-Host "Monitoring Ports: " -NoNewline
    $comPorts | ForEach-Object { 
        if ($_ -eq $comPort) { Write-Host "$_ (GPS)" -NoNewline -ForegroundColor Green } 
        else { Write-Host "$_ " -NoNewline }
    }
    Write-Host "`n"

    # Monitoring loop
    while ($true) {
        # Check for 'Q' to quit
        if ([System.Console]::KeyAvailable) {
            $key = [System.Console]::ReadKey($true)
            if ($key.Key -eq [System.ConsoleKey]::Q) { break }
        }

        $gpsData = Get-NmeaDataFromComPort -comPort $comPort

        if ($gpsData) {
            # Manage raw data buffer
            if ($rawDataBuffer.Count -ge $maxRawDataLines) {
                $rawDataBuffer.RemoveAt(0)
            }
            $rawDataBuffer.Add($gpsData.RawData) | Out-Null

            # Clear console except for the port list
            $host.UI.RawUI.CursorPosition = @{X=0;Y=2}
            Write-Host ("`n" * 50)

            # Raw Data Section
            Write-Host "Raw NMEA Data Stream:" -ForegroundColor Green
            foreach ($line in $rawDataBuffer) {
                Write-Host $line
            }

            # Parsed Data Section (ASCII Table)
            Write-Host "`n=======================================`n" -ForegroundColor Cyan
            Write-Host "Parsed GPS Information" -ForegroundColor Green
            
            $table = @"
+-------------------+------------------------+
| Parameter         | Value                  |
+-------------------+------------------------+
| Time              | $($gpsData.ParsedInfo.Time)
| Latitude          | $($gpsData.ParsedInfo.Latitude)
| Longitude         | $($gpsData.ParsedInfo.Longitude)
| Satellites        | $($gpsData.ParsedInfo.Satellites)
| Speed             | $($gpsData.ParsedInfo.Speed)
| Altitude          | $($gpsData.ParsedInfo.Altitude)
+-------------------+------------------------+
"@
            Write-Host $table

            # Timestamp
            Write-Host "`nLast Updated: $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')" -ForegroundColor DarkGray
        }
        else {
            Write-Host "No GPS data available on $comPort. Retrying..." -ForegroundColor Yellow
        }
        
        Start-Sleep -Milliseconds 500 # 0.5 seconds refresh rate
    }
}

# Check if port is provided as an argument
if ($args.Count -gt 0) {
    $selectedPort = $args[0]
}
else {
    $selectedPort = AutoSelectGpsPort
    if (-not $selectedPort) {
        Write-Host "No GPS device detected on any COM port. Please specify a port manually." -ForegroundColor Red
        $comPorts = [System.IO.Ports.SerialPort]::GetPortNames()
        if ($comPorts.Count -eq 0) {
            Write-Host "No COM ports found." -ForegroundColor Red
            exit
        }
        Write-Host "Available COM Ports:" -ForegroundColor Cyan
        for ($i = 0; $i -lt $comPorts.Count; $i++) {
            Write-Host "$($i + 1). $($comPorts[$i])" -ForegroundColor Green
        }
        $selection = Read-Host "Enter the number of the port to monitor"
        $selectedPort = $comPorts[$selection - 1]
    }
}

# Start monitoring
Start-GpsMonitor -comPort $selectedPort