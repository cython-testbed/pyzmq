@echo off
REM build a pyzmq release on Windows
REM 32+64b eggs on Python 27, 33, and wheels on 27, 33, 34
REM that's 10 bdists
REM requires Windows SDK 7.0 and 7.1
REM and Python installed in the locations: C:\Python34 (32b) and C:\Python34_64 (64b)

REM run with cmd.exe /k tools/release_windows.bat

setlocal EnableDelayedExpansion

set SDKS=C:\Program Files\Microsoft SDKs\Windows
set SDK7=%SDKS%\v7.0
set SDK71=%SDKS%\v7.1
set DISTUTILS_USE_SDK=1
set UPLOAD=upload

for %%p in (34, 33, 27) do (
  if "%%p"=="27" (
    set SDK=%SDK7%
  ) else (
    set SDK=%SDK71%
  )
  
  if "%%p"=="34" (
    set cmd=build bdist_wheel --zmq=bundled %UPLOAD%
  ) else (
    set cmd=build bdist_egg bdist_wheel --zmq=bundled %UPLOAD%
  )
  for %%b in (64, 32) do (
    if "%%b"=="64" (
      set SUFFIX=_64
      set ARCH=/x64
    ) else (
      set SUFFIX=
      set ARCH=/x86
    )
    set PY=C:\Python%%p!SUFFIX!\Python
    if not "%%p"=="27" set PY=!PY!
    echo !PY! !SDK!
    !PY! -m pip install --upgrade setuptools pip wheel
    
    @call "!SDK!\Bin\SetEnv.cmd" /release !ARCH!
    if !errorlevel! neq 0 exit /b !errorlevel!
    @echo on
    !PY! setupegg.py !cmd!
    @echo off
    if !errorlevel! neq 0 exit !errorlevel!
  )
)
exit