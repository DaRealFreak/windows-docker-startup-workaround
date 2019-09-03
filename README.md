The bug was fixed with the Docker Desktop 19.03 release, so I'm archiving this repository
---
# Windows Docker Startup Workaround


small collection of scripts to work with docker on windows.

## Usage
Just create a link to the [startup.bat](startup.bat) file in `%APPDATA%\Microsoft\Windows\Start Menu\Programs\Startup`.  
The startup.bat will start [startup_docker.bat](Scripts/startup_docker.bat).

## startup_docker.bat
The real reason why I wrote these scripts.This script is starting the powershell script [docker_restart_host_mount_workaround.ps1](Scripts/docker_restart_host_mount_workaround.ps1)
which is waiting for docker to be operational. It then waits additional 5 seconds to make sure docker started all the containers where some may crash because the host mount isn't ready yet.  
The get rid of the bound hosts (it is still bound to the container even though the container exited with an error code...) we restart the docker service afterwards.  
It then checks every running container if there is a mount on the host system or if they crashed with exit code 2 and restarts them.
This is a workaround for the bug of the empty mount on the host system after restarting in Windows. More information
to this bug can be found [here](https://github.com/docker/for-win/issues/584#issuecomment-286792858).
