%~d1
cd %1
for /F "tokens=*" %%A in ('dir /b/a-d') do @echo %%~dpnxA && @echo %%~dpnxA >> %~dp0myfile.txt
cd "%~dp0"
C:\Users\Public\Documents\DEMOS\windows-snapshot\bin\NavTestbed.exe ^
C:/Users/Public/Documents/jconf30/METaL.tracked.stereo.withwand.jconf C:/Users/Public/Documents/jconf30/mixins/METaL.wiimotewandbuttons.jconf ^
%~dp0\scripts\main_script_METaL_manip.lua %~dp0myfile.txt
DEL %~dp0myfile.txt
