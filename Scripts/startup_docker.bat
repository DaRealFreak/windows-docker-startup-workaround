@echo off
REM give windows time to mount the host system and for docker to start a bit
REM https://github.com/docker/for-win/issues/584#issuecomment-286792858
timeout 10 > NUL
echo Restarting containers with mounts on host volumes...
call PowerShell -NoProfile -ExecutionPolicy Bypass -Command "& '%~dp0\docker_restart_host_mount_workaround.ps1'"