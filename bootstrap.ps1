function Verify-Elevated {
    # Get the ID and security principal of the current user account
    $myIdentity=[System.Security.Principal.WindowsIdentity]::GetCurrent()
    $myPrincipal=new-object System.Security.Principal.WindowsPrincipal($myIdentity)
    # Check to see if we are currently running "as Administrator"
    return $myPrincipal.IsInRole([System.Security.Principal.WindowsBuiltInRole]::Administrator)
}

function Refresh-Environment {
    $locations = 'HKLM:\SYSTEM\CurrentControlSet\Control\Session Manager\Environment',
                 'HKCU:\Environment'

    $locations | ForEach-Object {
        $k = Get-Item $_
        $k.GetValueNames() | ForEach-Object {
            $name  = $_
            $value = $k.GetValue($_)
            Set-Item -Path Env:\$name -Value $value
        }
    }

    $env:Path = [System.Environment]::GetEnvironmentVariable("Path","Machine") + ";" + [System.Environment]::GetEnvironmentVariable("Path","User")
}

if (!(Verify-Elevated)) {
   $newProcess = new-object System.Diagnostics.ProcessStartInfo "PowerShell";
   $newProcess.Arguments = $myInvocation.MyCommand.Definition;
   $newProcess.Verb = "runas";
   [System.Diagnostics.Process]::Start($newProcess);

   exit
}

iex ((New-Object System.Net.WebClient).DownloadString('https://chocolatey.org/install.ps1'))

Write-Host "Refreshing environment" -ForegroundColor "Yellow"

Refresh-Environment

choco feature enable -n=allowGlobalConfirmation

Write-Host "Choco installing main components" -ForegroundColor "Yellow"

choco install git.install

choco install jq

iex ((New-Object System.Net.WebClient).DownloadString('https://raw.githubusercontent.com/softasap/sa-win/master/ConfigureRemotingForAnsible.ps1'))

iex ((New-Object System.Net.WebClient).DownloadString('https://raw.githubusercontent.com/softasap/sa-win/master/GetPowershell6LinuxRemoting.ps1'))
