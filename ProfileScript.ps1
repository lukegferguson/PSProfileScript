$profile_script_ver = "V.8"
#v9 once I get pulling installed applications
#v 1.0 once I get some rudumentary help written, at least a list of all the cmdlets included.

function Copy-PSprofile () {
$profile_path = "\\ms\userdata\035\lfergu10\Documents\2017 Scripting\ProfileScript\profilescript.ps1"
    if ((test-path $profile_path) -eq $false ) {write-host "Cannot access profile script path: $profile_path" -foregroundcolor red}
    else {copy-item -path $profile_path -destination $profile.CurrentUserAllHosts -force}
}

function Get-ProcT10 ($computername = $env:COMPUTERNAME) {
    get-process -ComputerName $computername | 
    Sort-Object ws -Descending | 
    Select-Object -First 10
}

function Get-DSM ($computername = $env:COMPUTERNAME, [switch] $online) { 
        $REGdsm = (invoke-command -computername $computername -erroraction stop { Get-ItemProperty -name DSIp "HKLM:\SOFTWARE\Altiris\Client Service" -erroraction stop })
        $name = ($regdsm.DSIp).Split("{.}") | Select-Object -First 1
        $url = "http://$name/DSWeb/default.aspx"

        $properties = @{'Name'=$name;
                        'URL'=$url}
                        
        $DSM = New-Object -TypeName psobject -Property $properties
        if  ($online -eq $true ) {start-process "C:\program files\internet explorer\iexplore.exe" $DSM.URL}
        else {Write-Output $dsm}
    #Function works! Tested local and remote.
    #-online switch opens DSM in IE window
    # set -erroraction to stop so that IE window won't open when accessing remote computer fails
    #https://technet.microsoft.com/en-us/library/hh750381.aspx - following this pretty exactly for creating custom object output.
    #Env:\LocalDSSServer is also DSM server. Wonder how PS gets that info.....
}

function Clear-Dns {ipconfig -flushdns} 

function Get-Uptime ($computername = $env:COMPUTERNAME){
    Get-CimInstance -ComputerName $computername -ClassName Win32_OperatingSystem | Select-Object csname, lastbootuptime
#useless improvement ideas: give time up in hours, days, weeks, etc
}

function Hide-Prompt {
    $Function:prompt = {
        $p = Split-Path -Leaf -Path (Get-Location)
        "$p> "
    }
    Write-Host "Prompt currently displaying only current folder, Show-Prompt to restore."
}

function Show-Prompt { 
    $Function:prompt = {
        $p = (Get-Location)
        "$p> "
    }
}

function Get-OPupdate ($computername = $env:COMPUTERNAME, [switch] $WebexBSOD, [switch] $CiscoVPN) {
    
    if ($WebexBSOD -eq $true) { 
        Get-HotFix -computername $computername -id KB4025341 | format-table -autosize
    }
<# Keeping this out of prod until I actually write it. 
    if ($CiscoVPN -eq $true) {
        write-host "I'll write this soon, for sure for promise. Uhhh, let me fake it. Robot voice: Your Cisco AnyConnect VPN client is currently version 4.2.01035"
    }
#>
}
<# 
error handling would be nice to figure out here CODE THIS NEXT
It's working! Caveat, it can return results from wrong machine name. Can I build in checker?
#>

function Test-OPconnection ($computername = "$env:COMPUTERNAME", $count = 1, [switch] $ms, [switch] $cshare){
    
    if($ms -eq $false) { $computername = "$computername.ms.ds.uhc.com" }
    
    if($cshare -eq $true) {
             $ipv4 = (Test-Connection -ComputerName $computername -buffersize 16 -count 1).IPV4Address.ipaddresstostring
             C:\windows\explorer.exe "\\$ipv4\c$\"
        }
    
        if ((Test-Connection -computername $computername -buffersize 16 -count $count -quiet) -eq $false) { 
            Write-host "$computername isn't resolving, attempting to connect..." -foregroundcolor "yellow"
            "Flushing DNS"
            ipconfig -flushdns | out-null
            "Registering DNS"
            ipconfig -registerdns | out-null
            "Testing connection..."
            if ((Test-Connection -computername $computername -buffersize 16 -count $count -quiet) -eq $false) {
                    write-host "$computername isn't resolving >:(" -foregroundcolor "red"
            }
            else { $ipv4 = Test-Connection -computername $computername -buffersize 16 -count 1
                    Write-host "$computername now resolves at" $ipv4.ipv4address.ToString() -ForegroundColor "green"
                    $ipv4 | Format-Table -AutoSize
            }
        }
        else { $ipv4 = Test-Connection -computername $computername -buffersize 16 -count 1
            Write-host "$computername resolves at" $ipv4.ipv4address.ToString() -ForegroundColor "green"
            $ipv4 | Format-Table -AutoSize
        }
}
#moved development of this to test_computername

function Hello {
    set-location "$env:userprofile\Documents\2017 Scripting"
    clear-host
    Write-Host "Profile Script version $profile_script_ver" -ForegroundColor Green
    write-host "PowerShell ready to roll."
    Hide-Prompt
}

Hello