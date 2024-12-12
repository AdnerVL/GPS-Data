# GPS Data Reader for Sierra Wireless Location Sensors 🌐📡🛰️

## Description 📝🗺️

This PowerShell script suite is designed to retrieve and display GPS data from Sierra Wireless Location Sensors on Windows systems. It utilizes:

- **Windows Location API** 🌍🧭 to fetch processed location data if available.
- **COM Port Reading** 🔌📟 to capture raw NMEA sentences from GPS devices connected via serial ports.

## Disclaimer 🤖🚧

**AI-Assisted Development** 🤝💡 This script was created with significant assistance from AI technologies. As the creator is not a professional PowerShell or software developer, the code reflects a collaborative approach between human intent and AI-generated solution.

## Features 🌟🔍

- **Automatic COM Port Detection** 📋🔎: Scans for and lists all available COM ports.
- **Multiple Data Sources** 🔄🌈:
  - Windows Location Service for high-level location data.
  - Direct COM port reading for raw GPS data (NMEA sentences).

## How to Use 🛠️👨‍💻

### Prerequisites ✔️🏁

- Windows OS with PowerShell 5.1 or higher 💻
- Administrative privileges might be necessary for accessing COM ports 🔐

### Installation 💾
No installation required; just run the script from PowerShell:

1. **Download or copy the script** 📥 to your local machine.
2. **Open PowerShell** 🖥️ as an Administrator if you encounter permission issues.

### Usage Steps 🚶‍♂️📝

1. **Open PowerShell** and navigate to the directory containing the script:
   ```powershell
   cd "path\to\your\script\directory"
   ```

2. **Run the script**:
   ```powershell
   .\GPSDataReader.ps1
   ```

## Outcome 📜🌍
 - Try to fetch location data via the Windows Location API. 🗺️
 - Scan for all available COM ports and attempt to read NMEA data from each.🔍

## Notes 📌🔬
 - COM Ports: 🔌 The script assumes a baud rate of 9600. Adjust this in the script if your device uses a different rate.
 - Data Output: 📊 Raw NMEA data might not be formatted; you'll see whatever comes through the port.
 - Error Handling: 🚨 Basic error handling is implemented, but you might encounter issues if ports are in use or not configured correctly.

## Customization 🔧🛠️
- Baud Rate: Change the $baudRate parameter in the Get-NmeaDataFromComPort function.
- Timeout: Adjust the ReadTimeout in the COM port reading function to optimize for your hardware.

## Troubleshooting 🚨🕵️‍♀️

### Common Issues 🔍🧩
No Data Detected 📡❌

 - Verify GPS sensor power and connection 🔋🔌
 - Check Device Manager for port conflicts 💻🚧
 - Ensure no other applications are using the COM port 🖥️🔒

### Permission Errors 🔐🚫

 - Run PowerShell as Administrator 👑💻
 - Verify user has necessary system permissions 🛡️👤
 - Check Windows Location Service settings ⚙️🌐

### Performance Problems 🐌⏱️

 - Increase ReadTimeout for slower devices 🕰️🐢
 - Verify device-specific communication parameters 📊🔧

## License 📜⚖️
This program is free software: you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation, either version 3 of the License, or (at your option) any later version.

This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.

You should have received a copy of the GNU General Public License along with this program. If not, see https://www.gnu.org/licenses/.

## Contributions 💡🤝
Pull requests are welcome! 🎉  For major changes, please open an issue first to discuss what you would like to change.

Happy GPS tracking! 🚀🌍🛰️
