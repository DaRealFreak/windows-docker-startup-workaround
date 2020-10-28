function Show-BalloonNotification($title, $message)
{
    [void] [System.Reflection.Assembly]::LoadWithPartialName("System.Windows.Forms")
    $objNotifyIcon = New-Object System.Windows.Forms.NotifyIcon
    $objNotifyIcon.Icon = [io.path]::combine($PSScriptRoot, '..', 'Icons/restart.ico')
    $objNotifyIcon.BalloonTipIcon = "Info"
    $objNotifyIcon.BalloonTipText = $message
    $objNotifyIcon.BalloonTipTitle = $title
    $objNotifyIcon.Visible = $True
    $objNotifyIcon.ShowBalloonTip(5000)
}

function Start-DockerService()
{
    # start the service and the tray process again
    Net start com.docker.service
    Start-Process "$env:ProgramFiles/Docker/Docker/Docker Desktop.exe"
}

function Shutdown-DockerService()
{
    # stop the service and kill the docker tray process
    Net stop com.docker.service
    Stop-Process -force -name "Docker Desktop"
    start-sleep 1
}

function Restart-WSL()
{
	wsl --shutdown
	start-sleep 1
	Start-Job -ScriptBlock {wsl}
}

function Get-AdminPrivilege()
{
    # Get the ID and security principal of the current user account
    $myWindowsID = [System.Security.Principal.WindowsIdentity]::GetCurrent();
    $myWindowsPrincipal = New-Object System.Security.Principal.WindowsPrincipal($myWindowsID);

    # Get the security principal for the administrator role
    $adminRole = [System.Security.Principal.WindowsBuiltInRole]::Administrator;

    # Check to see if we are currently running as an administrator
    if (!$myWindowsPrincipal.IsInRole($adminRole))
    {
        # We are not running as an administrator, so relaunch as administrator
        Start-Process powershell.exe " -NoProfile -ExecutionPolicy Bypass -File `"$PSCommandPath`"" -Verb RunAs -WindowStyle Hidden

        # Exit from the current, unelevated, process
        Exit;
    }
    else
    {
        # We are running as an administrator, so change the title and background colour to indicate this
        $Host.UI.RawUI.WindowTitle = $myInvocation.MyCommand.Definition + "(Elevated)";
    }
}


# Change to the current directory of the script, needed for elevated powershell
# since the default working directory is C:\Windows\system32 after starting
Set-Location $PSScriptRoot

# Get administrator privileges to be able to restart the docker service
Get-AdminPrivilege

# make sure the docker services are shut down before restarting the WSL service
# after restarting the WSL service we restart all docker services again
Show-BalloonNotification "Docker Workaround" "shutting down docker service and tray process"
Shutdown-DockerService
Show-BalloonNotification "Docker Workaround" "restarting WSL services"
Restart-WSL
# safety sleep since we don't wait for the output of the WSL command which would be waiting for an input on completion
start-sleep 3
Show-BalloonNotification "Docker Workaround" "restarting docker services"
Start-DockerService
