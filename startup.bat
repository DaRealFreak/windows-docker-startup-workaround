@echo off
wscript.exe "invisible.vbs" "Scripts/startup_acrylic.bat"
wscript.exe "invisible.vbs" "Scripts/startup_docker.bat"
wscript.exe "invisible.vbs" "Scripts/startup_docker_restart_containers.bat"
