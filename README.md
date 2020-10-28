The mount bug was reintroduced with the WSL2 containers
---
# Windows Docker Startup Workaround


small collection of scripts to work with docker on windows.

## Usage
Just create a link to the [startup.bat](startup.bat) file in `%APPDATA%\Microsoft\Windows\Start Menu\Programs\Startup`.  
The startup.bat will start [startup_docker.bat](Scripts/startup_docker.bat).

## startup_docker.bat
The real reason why I wrote these scripts. This script is starting the powershell script [docker_restart_host_mount_workaround.ps1](Scripts/docker_restart_host_mount_workaround.ps1)
which kills the current docker tray process and service. It then restarts the WSL service before restarting the docker tray process and service.
This is a workaround for the bug of the empty mount on the host system after restarting in Windows.
More information to this bug can be found [here](https://github.com/docker/for-win/issues/6822).
