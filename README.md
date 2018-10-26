# Windows Docker Startup Workaround
small collection of scripts to work with docker on windows.

## Usage
Just create a link to the [startup.bat](startup.bat) file in `%APPDATA%\Microsoft\Windows\Start Menu\Programs\Startup`.  
The startup.bat will start 3 different scripts, [startup_acrylic.bat](Scripts/startup_acrylic.bat), 
[startup_docker.bat](Scripts/startup_docker.bat) and [startup_docker_restart_containers.bat](Scripts/docker_restart_host_mount_container.ps1).

## startup_acrylic.bat
startup_acrylic.bat is trying to start the DNS proxy program [acrylic](https://mayakron.altervista.org/wikibase/show.php?id=AcrylicHome). 
If it isn't installed the script just closes without doing anything.

## startup_docker.bat
This is simply calling the docker start file in Windows. Since putting docker in the autostart fails in 
more than 50% of the restarts in my case(files already in host mount, port binding failed, ...) it waits additional 10 
seconds before starting the program.

## startup_docker_restart_containers.bat
The real reason why I wrote these scripts.This script is starting the powershell script [docker_restart_host_mount_container.ps1](Scripts/docker_restart_host_mount_container.ps1)
which is waiting for docker to be operational. It then waits additional 10 seconds to make sure the host mount is ready.  
It then checks every running container if there is a mount on the host system and restarts them.
This is a workaround for the bug of the empty mount on the host system after restarting in Windows. More information
to this bug can be found [here](https://github.com/docker/for-win/issues/584#issuecomment-286792858).