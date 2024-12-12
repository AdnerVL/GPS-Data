# Modules and COM objects needed
Add-Type -AssemblyName System.IO.Ports

# Function to get all available COM ports
function Get-ExistingComPorts {
    return [System.IO.Ports.SerialPort]::getportnames()
}

# Function using Windows Location API for comparison
function Get-WindowsLocation {
    try {
        $location = New-Object -ComObject LocationDisp.LatLongReportFactory
        $status = $location.Status
        if ($status -eq 4) { # Status 4 means "Running"
            $lat = $location.LatLongReport.Latitude
            $long = $location.LatLongReport.Longitude
            Write-Host "Windows Location API - Lat: $lat, Long: $long"
        } else {
            Write-Host "Windows Location API - Service not running. Status: $status"
        }
    } catch {
        Write-Host "Windows Location API - Error accessing location data: $_"
    }
}

# Function to attempt reading NMEA data from a specific COM port
function Get-NmeaDataFromComPort {
    param (
        [string]$comPort,
        [int]$baudRate = 9600
    )
    
    $port = New-Object System.IO.Ports.SerialPort $comPort, $baudRate, None, 8, one
    try {
        $port.Open()
        $port.ReadTimeout = 500
        Write-Host "Reading NMEA data from $comPort..."
        while ($true) {
            $data = $port.ReadLine()
            if ($data) {
                Write-Host "$comPort - $data"
            }
        }
    }
    catch {
        Write-Host "Error reading from ${comPort}: $_"
    }
    finally {
        if ($port.IsOpen) {
            $port.Close()
        }
    }
}

# Function to try reading data from all available COM ports
function Get-DataFromAllComPorts {
    $comPorts = Get-ExistingComPorts
    if ($comPorts.Count -eq 0) {
        Write-Host "No COM ports found."
        return
    }

    foreach ($port in $comPorts) {
        Write-Host "`nChecking port: $port"
        try {
            Get-NmeaDataFromComPort -comPort $port -baudRate 9600
        }
        catch {
            Write-Host "Failed to read from ${port}: $_"
        }
    }
}

# Main execution
Write-Host "Attempting to get data from Windows Location API..."
Get-WindowsLocation

Write-Host "`nAttempting to get data from all available COM ports..."
Get-DataFromAllComPorts