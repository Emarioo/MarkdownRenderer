@echo off
@setlocal enabledelayedexpansion

SET USE_DEBUG=1
@REM SET USE_OPTIMIZATIONS=1

@REM Advapi is used for winreg which accesses the windows registry
@REM to get cpu clock frequency which is used with rdtsc.
@REM I have not found an easier way to get the frequency.

if !USE_OPTIMIZATIONS!==1 (
    SET MSVC_COMPILE_OPTIONS=/std:c++14 /nologo /TP /EHsc /O2
) else (
    SET MSVC_COMPILE_OPTIONS=/std:c++14 /nologo /TP /EHsc
)

SET MSVC_LINK_OPTIONS=/NOLOGO /INCREMENTAL:NO /ignore:4099 Advapi32.lib gdi32.lib shell32.lib user32.lib OpenGL32.lib
SET MSVC_INCLUDE_DIRS=/Iinclude /Ilibs/stb/include /Ilibs/glfw-3.3.8/include /Ilibs/glew-2.1.0/include /Ilibs/glm/include
SET MSVC_DEFINITIONS=/DOS_WINDOWS /FI pch.h

SET MSVC_LINK_OPTIONS=!MSVC_LINK_OPTIONS! libs/glfw-3.3.8/lib/glfw3_mt.lib libs/glew-2.1.0/lib/glew32s.lib
SET MSVC_DEFINITIONS=!MSVC_DEFINITIONS! /DGLEW_STATIC


if !USE_DEBUG!==1 (
    SET MSVC_COMPILE_OPTIONS=!MSVC_COMPILE_OPTIONS! /Zi
    SET MSVC_LINK_OPTIONS=!MSVC_LINK_OPTIONS! /DEBUG /PROFILE
)

mkdir bin 2> nul

SET srcfile=bin\all.cpp
SET srcfiles=
SET output=bin\prog.exe

type nul > !srcfile!
for /r %%i in (*.cpp) do (
    SET file=%%i
    if "x!file:__=!"=="x!file!" if "x!file:bin=!"=="x!file!" (
        if not "x!file:mdrend=!"=="x!file!" (
            echo #include ^"!file:\=/!^">> !srcfile!
        ) else if not "x!file:Engone=!"=="x!file!" (
            echo #include ^"!file:\=/!^">> !srcfile!
        )
    )
)

set /a startTime=6000*( 100%time:~3,2% %% 100 ) + 100* ( 100%time:~6,2% %% 100 ) + ( 100%time:~9,2% %% 100 )

SET compileSuccess=0

cl /c !MSVC_COMPILE_OPTIONS! !MSVC_INCLUDE_DIRS! !MSVC_DEFINITIONS! !srcfile! /Fobin/all.obj
link bin\all.obj !MSVC_LINK_OPTIONS! /OUT:!output!
SET compileSuccess=!errorlevel!

set /a endTime=6000*(100%time:~3,2% %% 100 )+100*(100%time:~6,2% %% 100 )+(100%time:~9,2% %% 100 )
set /a finS=(endTime-startTime)/100
set /a finS2=(endTime-startTime)%%100

echo Compiled in %finS%.%finS2% seconds

if !compileSuccess! == 0 if not !ONLY_HOT_RELOAD!==1 (
    @REM echo f | XCOPY /y /q !output! prog.exe > nul
    bin\prog.exe
)