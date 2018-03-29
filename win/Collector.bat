@ECHO OFF
REM # ============================================================================
REM # Description: Runs the modules in the provided list
REM # Arguments:
REM # 	ModulePath - 
REM # 	OutputPath -
REM #
REM # Example
REM # .\Collection_Scripts\Collect_Light.bat 
REM # C:\Users\connor\Documents\output\
REM # C:\Users\connor\Documents\YACK\win\
REM # C:\Users\connor\Documents\YACK\win\Settings\Light_List.txt
REM # ============================================================================

REM # Allows expansion in for loops
setlocal ENABLEDELAYEDEXPANSION


REM # Parse arguments
set OutputPath=%1
SET ContentPath=%2
SET ModuleListPath=%3

call :Initialize
call :RunModules

Exit /B 0



:Initialize

	REM # Set Variables
	SET ModuleFolderPath=%ContentPath%\Modules\

	REM # Create Log File
	echo # Don't modify the log format unless you modify the monitor script to match > %OutputPath%\StatusLog.txt
	
	REM # Get module count
	set /a TotalModuleCount=0
	FOR /F "eol=# delims=, " %%i in (%ModuleListPath%) do (
		set /a TotalModuleCount=TotalModuleCount+1
	)
	
	Exit /B 0


:RunModules
	set /a CurrentCount=0
	
	REM # Loop through the modules in the list
	FOR /F "eol=# " %%i in (%ModuleListPath%) do (
		REM # Increment counter
		set /a CurrentCount=!CurrentCount!+1
		
		REM # Log the module attempting to be ran
		call :LogModule %%i !CurrentCount!
		
			
		REM # Check if the Module Exists
		if exist "%ModuleFolderPath%%%i" (
		
			REM # Run the module
			call :RunModule %%i
			
		) else (
		
			REM # Log that it wasn't found.
			echo    Module was not found. 
			echo    Module was not found. >> %OutputPath%\StatusLog.txt
		)
	)
	
	REM # Log the "Complete" which is used to cue the launched script
	echo Complete >> %OutputPath%\StatusLog.txt
	
	Exit /B 0


:RunModule
	SET Param_ModuleRelPath=%~1
	
	REM # Determine module type
	set "FullModulePath=%ModuleFolderPath%%Param_ModuleRelPath%"
	for /f "delims=" %%a  in ("%FullModulePath%") do set "ModuleFileExtension=%%~xa"
	
	REM # batch file
	if /i "%ModuleFileExtension%" EQU ".bat" (
		call "%ModuleFolderPath%%Param_ModuleRelPath%" %ModuleFolderPath% %OutputPath%
	)
	
	REM # powershell file
	if /i "%ModuleFileExtension%" EQU ".ps1" (
		PowerShell -ExecutionPolicy Bypass -Command "%ModuleFolderPath%%Param_ModuleRelPath% %ModuleFolderPath% %OutputPath% "
	
	)
	
	Exit /B 0


:LogModule
	SET Param_ModuleRelPath=%~1
	SET Param_ModuleCurrentCount=%~2

	call :Update_UTCtimestamp
	
	REM # Format of the output
	set "LogOutput=echo %UTCtimestamp% :: %Param_ModuleCurrentCount% / %TotalModuleCount% :: Running %Param_ModuleRelPath%"
	echo %LogOutput%
	echo %LogOutput% >> %OutputPath%\StatusLog.txt

	Exit /B 0


Rem # ISO 8601 format
:Update_UTCtimestamp
	
	for /f "delims=" %%a in ('wmic OS Get localdatetime  ^| find "."') do set "dt=%%a"
	set "TS_YYYY=%dt:~0,4%"
	set "TS_MM=%dt:~4,2%"
	set "TS_DD=%dt:~6,2%"
	set "TS_HH=%dt:~8,2%"
	set "TS_Min=%dt:~10,2%"
	set "TS_Sec=%dt:~12,2%"
	set "TS_Milisec=%dt:~15,3%"
	set "TS_PlusMinus=%dt:~21,1%"
	set /a "TZ_Mins=%dt:~22,3%"
	
	REM # Calc timezone offset
	set /a "TZ_Hours=%TZ_Mins%/60"
	set /a "TZ_Mins_Mod=%TZ_Mins%%%60"

	REM # Pad zeros
	IF %TZ_Hours% LSS 10 SET TZ_Hours=0%TZ_Hours%
	IF %TZ_Mins_Mod% LSS 10 SET TZ_Mins_Mod=0%TZ_Mins_Mod%

	set UTCtimestamp=%TS_YYYY%-%TS_MM%-%TS_DD%T%TS_HH%:%TS_Min%:%TS_Sec%.%TS_Milisec%%TS_PlusMinus%%TZ_Hours%:%TZ_Mins_Mod%
	
	Exit /B 0


	