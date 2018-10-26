@echo off
wscript.exe "%~dp0\Scripts\invisible.vbs" "%~dp0\Scripts\startup_acrylic.bat"
wscript.exe "%~dp0\Scripts\invisible.vbs" "%~dp0\Scripts\startup_docker.bat"
wscript.exe "%~dp0\Scripts\invisible.vbs" "%~dp0\Scripts\startup_docker_restart_containers.bat"
