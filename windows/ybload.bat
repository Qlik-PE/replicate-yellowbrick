@echo off

SET YBLOAD_EXE="C:\Program Files\Yellowbrick Data\Client Tools\bin\ybload.exe"

echo %date%:%time% ybload.bat: arguments: %*

if %~1 equ -V ( 
   echo ybload.bat - map arguments from Replicate to Yellowbrick 'ybload'
   %YBLOAD_EXE% --version
   goto done
)

SET PSQLFILE=%5
SET ARGS=%~6

echo %date%:%time% ybload.bat: LOAD FILE %PSQLFILE% 

REM PSQLFILE is a file that contains the following copy command which is passed to psql.
REM \copy "owner"."table" from 'filename.csv' WITH DELIMITER ',' CSV NULL 'attNULL' ESCAPE '\'
for /F usebackq^ tokens^=1^-6^*^ delims^=^'^" %%A in (%PSQLFILE%) do (
   set SCHEMA=%%B
   set TABLE=%%D
   set CSVFILE=%%F
)

for /F "tokens=1-8 delims== " %%L IN ("%ARGS%") do (
   set SERVER=%%M
   set PORT=%%O
   set USERNAME=%%Q
   set DATABASE=%%S
)

SET YBPASSWORD=%PGPASSWORD%

%YBLOAD_EXE% -h %SERVER% -p %PORT% ^
    -U %USERNAME% -d %DATABASE% --format CSV --escape-char ^"\\^"  ^
	-t \"%SCHEMA%\".\"%TABLE%\" --nullmarker attNULL "%CSVFILE%"

:done

	