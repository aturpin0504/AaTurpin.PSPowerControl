Add-Type -TypeDefinition @"
using System;
using System.Runtime.InteropServices;
public class SleepControl {
    [DllImport("kernel32.dll")]
    public static extern uint SetThreadExecutionState(uint esFlags);
    
    public const uint ES_CONTINUOUS = 0x80000000;
    public const uint ES_SYSTEM_REQUIRED = 0x00000001;
    public const uint ES_DISPLAY_REQUIRED = 0x00000002;
}
"@

function Set-SleepState {
    <#
    .SYNOPSIS
        Controls system sleep behavior.
    
    .PARAMETER Disable
        If specified, disables sleep. Otherwise enables normal sleep behavior.
    
    .PARAMETER LogPath
        Path to log file for recording operations.
    
    .EXAMPLE
        Set-SleepState -Disable -LogPath "C:\Logs\power.log"
        Prevents both system and monitor sleep
    
    .EXAMPLE
        Set-SleepState -LogPath "C:\Logs\power.log"
        Restores normal power management
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $false)]
        [switch]$Disable,
        
        [Parameter(Mandatory = $true)]
        [string]$LogPath
    )
    
    $operation = if ($Disable) { "disable" } else { "enable" }
    $flags = if ($Disable) { 
        [SleepControl]::ES_CONTINUOUS -bor [SleepControl]::ES_SYSTEM_REQUIRED -bor [SleepControl]::ES_DISPLAY_REQUIRED 
    } else { 
        [SleepControl]::ES_CONTINUOUS 
    }
    
    try {
        Write-LogInfo -LogPath $LogPath -Message "Starting sleep $operation operation"
        
        $result = [SleepControl]::SetThreadExecutionState($flags)
        if ($result -eq 0) { 
            $errorMsg = "Failed to $operation sleep: SetThreadExecutionState API call failed. This may indicate insufficient privileges or a system power management conflict."
            throw $errorMsg
        }
        
        $successMsg = if ($Disable) { "Successfully disabled system and monitor sleep" } else { "Successfully re-enabled normal sleep behavior" }
        Write-LogInfo -LogPath $LogPath -Message $successMsg
        Write-Host "Sleep $operation completed successfully" -ForegroundColor Green
    }
    catch {
        $errorMsg = "Failed to $operation sleep: $($_.Exception.Message)"
        Write-LogError -LogPath $LogPath -Message $errorMsg -Exception $_.Exception
        throw $errorMsg
    }
}

function Disable-Sleep {
    <#
    .SYNOPSIS
        Prevents system and monitor from sleeping.
    
    .PARAMETER LogPath
        Path to log file for recording operations.
    
    .EXAMPLE
        Disable-Sleep -LogPath "C:\Logs\power.log"
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [string]$LogPath
    )
    
    Set-SleepState -Disable -LogPath $LogPath
}

function Enable-Sleep {
    <#
    .SYNOPSIS
        Re-enables normal sleep behavior.
    
    .PARAMETER LogPath
        Path to log file for recording operations.
    
    .EXAMPLE
        Enable-Sleep -LogPath "C:\Logs\power.log"
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [string]$LogPath
    )
    
    Set-SleepState -LogPath $LogPath
}

Export-ModuleMember -Function Disable-Sleep, Enable-Sleep