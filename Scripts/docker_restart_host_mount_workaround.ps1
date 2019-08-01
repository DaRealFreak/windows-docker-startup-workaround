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


function Wait-DockerService()
{
    # docker not available yet can return two possible messages:
    # 1. error during connect: Get http://%2F%2F.%2Fpipe%2Fdocker_engine/v1.38/containers/json: open //./pipe/docker_engine: The system cannot find the file specified. In the default daemon configuration on Windows, the docker client must be run elevated to connect. This error may also indicate that the docker daemon is not running.
    # 2. Error response from daemon: An invalid argument was supplied.
    # 3. Error response from daemon: i/o timeout
    $response = docker ps
    While (($null -eq $response) -or ($true -ne $response.Contains('CONTAINER ID')))
    {
        Write-Output "docker is not available yet, sleeping..."
        start-sleep 2
        $response = docker ps
    }
    Write-Output "docker is available now"
}

function Start-DockerService()
{
    # start the service and the tray process again
    Net start com.docker.service
    Start-Process "C:/Program Files/Docker/Docker/Docker Desktop.exe"
    # wait until the service booted up
    Wait-DockerService
}

function Restart-DockerService()
{
    # stop the service and kill the docker tray process
    Net stop com.docker.service
    Stop-Process -force -name "Docker Desktop"
    start-sleep 1
    Start-DockerService
}

function Restart-Containers($containers)
{
    foreach ($containerId in $containers)
    {
        $mounts = (docker inspect -f "{{ .Mounts }}" $containerId)
        if ( $mounts.Contains("host_mnt"))
        {
            $containerName = (docker inspect --format ="{{.Name}}" $containerId)
            Show-BalloonNotification "Docker Workaround" "Restarting $containerName..."
            docker restart $containerId
        }
    }
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

# we first start the docker service
# it will automatically restart containers which were active when we shut down windows
# if these containers have a mount on the host system they'll exit (exit code 2) but the bound port is still occupied
# so we restart the whole docker service again before restarting all containers with a mount on the host system
# and crashed containers(exit code 2)
Show-BalloonNotification "Docker Workaround" "Starting the docker service"
Start-DockerService
Show-BalloonNotification "Docker Workaround" "Restarting the docker service to get rid of the port bindings"
Restart-DockerService

$runningContainers = (docker ps -q).Split([Environment]::NewLine)
$exitedContainers
if (docker container ls -q -f 'status=exited' -f 'exited=2')
{
    $exitedContainers += (docker container ls -q -f 'status=exited' -f 'exited=2').Split([Environment]::NewLine)
}
if (docker container ls -q -f 'status=exited' -f 'exited=128')
{
    $exitedContainers += (docker container ls -q -f 'status=exited' -f 'exited=128').Split([Environment]::NewLine) | Select-Object -uniq
}

Restart-Containers $runningContainers
Restart-Containers $exitedContainers