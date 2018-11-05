function Balloon-Notification($title, $message)
{
    [void] [System.Reflection.Assembly]::LoadWithPartialName("System.Windows.Forms")
    $objNotifyIcon = New-Object System.Windows.Forms.NotifyIcon
    $objNotifyIcon.Icon = "$PSScriptRoot\..\Icons\restart.ico"
    $objNotifyIcon.BalloonTipIcon = "Info"
    $objNotifyIcon.BalloonTipText = $message
    $objNotifyIcon.BalloonTipTitle = $title
    $objNotifyIcon.Visible = $True
    $objNotifyIcon.ShowBalloonTip(5000)
}

function Wait-For-Docker-Service()
{
    # docker not available yet can return two possible messages:
    # 1. error during connect: Get http://%2F%2F.%2Fpipe%2Fdocker_engine/v1.38/containers/json: open //./pipe/docker_engine: The system cannot find the file specified. In the default daemon configuration on Windows, the docker client must be run elevated to connect. This error may also indicate that the docker daemon is not running.
    # 2. Error response from daemon: An invalid argument was supplied.
    $response = docker ps
    While (($response -eq $null) -or ($response.Contains('CONTAINER ID') -ne $false))
    {
        echo "docker is not available yet, sleeping..."
        start-sleep 2
        $response = docker ps
    }
    echo "docker is available now"
    # sleep few more seconds to let docker start the containers
    start-sleep 5
}

function Start-Docker-Service()
{
    # start the service and the tray process again
    Net start com.docker.service
    Start-Process "C:/Program Files/Docker/Docker/Docker for Windows.exe"
    # wait until the service booted up
    Wait-For-Docker-Service
}

function Restart-Docker-Service()
{
    # stop the service and kill the docker tray process
    Net stop com.docker.service
    Stop-Process -force -name "Docker for Windows"
    start-sleep 1
    # start the services again
    Start-Docker-Service
}

function Restart-Containers($containers)
{
    foreach ($containerId in $containers) {
        $mounts = (docker inspect -f "{{ .Mounts }}" $containerId)
        if ($mounts.Contains("host_mnt")) {
            $containerName = docker inspect --format="{{.Name}}" $containerId
            Balloon-Notification "Restarting container..." $containerName
            docker restart $containerName
        }
    }
}

# we first start the docker service
# it will automatically restart containers which were active when we shut down windows
# if these containers have a mount on the host system they'll exit (exit code 2) but the bound port is still occupied
# so we restart the whole docker service again before restarting all containers with a mount on the host system
# and crashed containers(exit code 2)
Start-Docker-Service
Restart-Docker-Service

$runningContainers = (docker ps -q).Split([Environment]::NewLine)
$exitedContainers = (docker container ls -q -f 'status=exited' -f 'exited=2').Split([Environment]::NewLine)
Restart-Containers $runningContainers
Restart-Containers $exitedContainers

