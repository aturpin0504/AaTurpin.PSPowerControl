# AaTurpin.PSPowerControl

A PowerShell module for controlling Windows power management settings, including the ability to prevent system and monitor sleep during critical operations. Uses Windows API calls for reliable power state management.

## Features

- **Disable System Sleep**: Prevent the system from entering sleep mode during critical operations
- **Disable Monitor Sleep**: Keep the display active to prevent screen timeout
- **Restore Normal Power Management**: Re-enable standard Windows power management behavior
- **Thread-Safe Logging**: Integrated with AaTurpin.PSLogger for comprehensive operation logging
- **Windows API Integration**: Uses kernel32.dll SetThreadExecutionState for reliable power control
- **Error Handling**: Comprehensive error handling with detailed logging and user feedback

## Installation

### From PowerShell Gallery

```powershell
Install-Module -Name AaTurpin.PSPowerControl -Scope CurrentUser
```

### Import the Module

```powershell
Import-Module AaTurpin.PSPowerControl
```

## Prerequisites

- **PowerShell**: Version 5.1 or higher
- **Operating System**: Windows (uses Windows-specific APIs)
- **Dependencies**: AaTurpin.PSLogger module (automatically installed)
- **Permissions**: Standard user permissions (no administrative privileges required)

## Quick Start

```powershell
# Import the module
Import-Module AaTurpin.PSPowerControl

# Disable sleep during a critical operation
Disable-Sleep -LogPath "C:\Logs\power.log"

# Your critical work here...
Start-Sleep -Seconds 10

# Re-enable normal sleep behavior
Enable-Sleep -LogPath "C:\Logs\power.log"
```

## Functions

### Disable-Sleep

Prevents both system and monitor from entering sleep mode.

**Syntax:**
```powershell
Disable-Sleep -LogPath <String>
```

**Parameters:**
- `-LogPath` (Required): Path to the log file for recording operations

**Example:**
```powershell
Disable-Sleep -LogPath "C:\Logs\power.log"
```

### Enable-Sleep

Re-enables normal Windows power management behavior.

**Syntax:**
```powershell
Enable-Sleep -LogPath <String>
```

**Parameters:**
- `-LogPath` (Required): Path to the log file for recording operations

**Example:**
```powershell
Enable-Sleep -LogPath "C:\Logs\power.log"
```

## Common Use Cases

### Long-Running Scripts

```powershell
Import-Module AaTurpin.PSPowerControl

try {
    # Disable sleep for the duration of the script
    Disable-Sleep -LogPath "C:\Logs\maintenance.log"
    
    # Perform long-running maintenance tasks
    Write-Host "Starting system maintenance..."
    
    # Your maintenance code here
    Start-Process "backup-script.ps1" -Wait
    Start-Process "system-cleanup.ps1" -Wait
    
    Write-Host "Maintenance completed successfully"
}
finally {
    # Always re-enable sleep in the finally block
    Enable-Sleep -LogPath "C:\Logs\maintenance.log"
    Write-Host "Normal power management restored"
}
```

### File Transfer Operations

```powershell
Import-Module AaTurpin.PSPowerControl

# Prevent sleep during large file transfers
Disable-Sleep -LogPath "C:\Logs\transfer.log"

try {
    # Perform file transfer operations
    Copy-Item "\\server\largefile.zip" -Destination "C:\Local\" -Verbose
    
    # Additional transfer operations...
}
catch {
    Write-Error "Transfer failed: $($_.Exception.Message)"
}
finally {
    # Restore normal power management
    Enable-Sleep -LogPath "C:\Logs\transfer.log"
}
```

### Automated Deployments

```powershell
Import-Module AaTurpin.PSPowerControl

function Start-UnattendedDeployment {
    param($LogPath = "C:\Logs\deployment.log")
    
    try {
        # Disable sleep for unattended deployment
        Disable-Sleep -LogPath $LogPath
        
        Write-Host "Starting unattended deployment..." -ForegroundColor Green
        
        # Deployment steps
        Install-Applications
        Configure-Services
        Update-Registry
        
        Write-Host "Deployment completed successfully" -ForegroundColor Green
    }
    catch {
        Write-Error "Deployment failed: $($_.Exception.Message)"
        throw
    }
    finally {
        # Always restore power management
        Enable-Sleep -LogPath $LogPath
        Write-Host "Power management restored" -ForegroundColor Yellow
    }
}
```

## Technical Details

### Windows API Integration

The module uses the Windows `SetThreadExecutionState` API from kernel32.dll to control power management:

- **ES_CONTINUOUS**: Informs the system that the state being set should remain in effect until the next call
- **ES_SYSTEM_REQUIRED**: Forces the system to be in the working state by resetting the system idle timer
- **ES_DISPLAY_REQUIRED**: Forces the display to be on by resetting the display idle timer

### Thread Execution States

When sleep is disabled, the module sets the following execution state flags:
```
ES_CONTINUOUS | ES_SYSTEM_REQUIRED | ES_DISPLAY_REQUIRED
```

When sleep is enabled, only the ES_CONTINUOUS flag is set, allowing normal power management to resume.

## Error Handling

The module provides comprehensive error handling:

- **API Call Failures**: Detects when SetThreadExecutionState returns 0 (failure)
- **Privilege Issues**: Provides clear error messages for insufficient privileges
- **System Conflicts**: Handles power management conflicts with detailed logging
- **Exception Logging**: All errors are logged using AaTurpin.PSLogger with full exception details

## Logging Integration

All operations are logged using the AaTurpin.PSLogger module:

- **Info Level**: Successful operations and state changes
- **Error Level**: Failed operations with exception details
- **Debug Level**: Internal API call results and state information

Example log entries:
```
[2025-07-03 14:30:15.123] [Information] Starting sleep disable operation
[2025-07-03 14:30:15.145] [Information] Successfully disabled system and monitor sleep
[2025-07-03 14:35:22.456] [Information] Starting sleep enable operation
[2025-07-03 14:35:22.467] [Information] Successfully re-enabled normal sleep behavior
```

## Best Practices

1. **Always Use Try-Finally**: Ensure sleep is re-enabled even if your script encounters errors
2. **Limit Usage Duration**: Only disable sleep for the minimum time necessary
3. **Log All Operations**: Always provide a log path for troubleshooting
4. **Test Permissions**: Verify the module works in your environment before production use
5. **Monitor System Resources**: Be aware that preventing sleep may impact system performance

## Troubleshooting

### Common Issues

**Q: Function returns "SetThreadExecutionState API call failed"**
A: This typically indicates:
- System power policy conflicts
- Hardware-specific power management issues
- Try running PowerShell as Administrator

**Q: Sleep is not actually prevented**
A: Check:
- Windows power plan settings may override API calls
- Some hardware may have firmware-level sleep controls
- Group Policy settings might enforce power management

**Q: Module fails to import**
A: Ensure:
- PowerShell 5.1 or higher is installed
- AaTurpin.PSLogger dependency is available
- No PowerShell execution policy restrictions

### Getting Help

1. **Check Logs**: Review the log files for detailed error information
2. **Verify Dependencies**: Ensure AaTurpin.PSLogger is properly installed
3. **Test Basic Functionality**: Try the Quick Start example
4. **System Compatibility**: Verify Windows version compatibility

## Contributing

Contributions are welcome! Please feel free to submit issues, feature requests, or pull requests on the project repository.

## License

This project is licensed under the MIT License. See the LICENSE file for details.

## Links

- **Project Repository**: https://github.com/aturpin0504/AaTurpin.PSPowerControl
- **PowerShell Gallery**: [AaTurpin.PSPowerControl](https://www.powershellgallery.com/packages/AaTurpin.PSPowerControl)
- **License**: https://github.com/aturpin0504/AaTurpin.PSPowerControl?tab=MIT-1-ov-file
- **Related Modules**: [AaTurpin.PSLogger](https://github.com/aturpin0504/AaTurpin.PSLogger)

## Version History

### 1.0.0 (Initial Release)
- Windows power management control capabilities
- Functions to disable and enable system/monitor sleep
- Windows kernel32.dll API integration for reliable power state management
- Comprehensive error handling and logging integration
- Thread-safe operations with AaTurpin.PSLogger integration