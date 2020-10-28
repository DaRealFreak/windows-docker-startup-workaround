@echo off
REM give WSL time to mount the host system
REM https://github.com/docker/for-win/issues/6822
call PowerShell -NoProfile -ExecutionPolicy Bypass -Command "& '%~dp0\docker_restart_host_mount_workaround.ps1'"