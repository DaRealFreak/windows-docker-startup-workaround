function balloonNotification($title, $message)
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
# sleep few more seconds to let docker start the other containers
start-sleep 10
$runningContainer = (docker ps -q).Split([Environment]::NewLine)

foreach ($containerId in $runningContainer) {
    $mounts = (docker inspect -f "{{ .Mounts }}" $containerId)
    if ($mounts.Contains("host_mnt")) {
        $containerName = docker inspect --format="{{.Name}}" $containerId
        balloonNotification "Restarting container..." $containerName
        docker restart $containerName
    }
}