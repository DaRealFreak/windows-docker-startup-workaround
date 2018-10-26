@echo off
REM give windows time to mount the host system
timeout 10 > NUL
echo Starting "Docker for Windows.exe"
"C:/Program Files/Docker/Docker/Docker for Windows.exe"