REM Final processing batch file run after all block processing is complete

REM file name for the list of block outputs...this is needed to merge block outputs into single layers
SET FOLDERLIST=%WORKINGDIRNAME%\OutputFolders.txt

REM read first folder containing block outputs
SET /p TEMPLATE=< "%FOLDERLIST%"

REM do the metrics
IF /I "%MERGEBLOCKMETRICS%"=="true" (
	IF /I "%DOMETRICS%"=="true" (
		REM build a list of all the files in the folder
		DIR /b /o:n "%TEMPLATE%\Metrics_%FILEIDENTIFIER%\*.asc">layerlist.txt

		REM step through the list of layers and merge each layer with the same name across the blocks
		FOR /F %%i IN (layerlist.txt) DO CALL "%PROCESSINGHOME%\mergelayer" %%i 1 "%FINALPRODUCTHOME%\Metrics_%FILEIDENTIFIER%"
	)

	REM look for strata
	IF /I "%DOSTRATA%"=="true" (
		REM build a list of all the files in the folder
		DIR /b /o:n "%TEMPLATE%\StrataMetrics_%FILEIDENTIFIER%\*.asc">layerlist.txt

		REM step through the list of layers and merge each layer with the same name across the blocks
		FOR /F %%i IN (layerlist.txt) DO CALL "%PROCESSINGHOME%\mergelayer" %%i 1 "%FINALPRODUCTHOME%\StrataMetrics_%FILEIDENTIFIER%"
	)

	REM look for canopy surface metrics
	IF /I "%DOCANOPY%"=="true" (
		REM build a list of all the files in the folder
		DIR /b /o:n "%TEMPLATE%\CanopyMetrics_%CANOPYSTATSFILEIDENTIFIER%\*.asc">layerlist.txt

		REM step through the list of layers and merge each layer with the same name across the blocks
		FOR /F %%i IN (layerlist.txt) DO CALL "%PROCESSINGHOME%\mergelayer" %%i 1 "%FINALPRODUCTHOME%\CanopyMetrics_%CANOPYSTATSFILEIDENTIFIER%"
	)
)

REM do the canopy
IF /I "%MERGEBLOCKCANOPY%"=="true" (
	IF /I "%DOCANOPY%"=="true" (
		REM build a list of all the files in the folder
		DIR /b /o:n "%TEMPLATE%\CanopyHeight_%CANOPYFILEIDENTIFIER%\CHM_*.dtm">layerlist.txt

		REM step through the list of layers and merge each layer with the same name across the blocks
		FOR /F %%i IN (layerlist.txt) DO CALL "%PROCESSINGHOME%\mergelayer" %%i 2 "%FINALPRODUCTHOME%\CanopyHeight_%CANOPYFILEIDENTIFIER%"

		IF /I [%DOSPECIALCANOPY%]==[true] (
			REM merge the lower resolution canopy surfaces...same logic as above but different folders
			DIR /b /o:n "%TEMPLATE%\CanopyHeight_%CANOPYFILEIDENTIFIER1%\CHM_*.dtm">layerlist.txt
			FOR /F %%i IN (layerlist.txt) DO CALL "%PROCESSINGHOME%\mergelayer" %%i 2 "%FINALPRODUCTHOME%\CanopyHeight_%CANOPYFILEIDENTIFIER1%"

			DIR /b /o:n "%TEMPLATE%\CanopyHeight_%CANOPYFILEIDENTIFIER2%\CHM_*.dtm">layerlist.txt
			FOR /F %%i IN (layerlist.txt) DO CALL "%PROCESSINGHOME%\mergelayer" %%i 2 "%FINALPRODUCTHOME%\CanopyHeight_%CANOPYFILEIDENTIFIER2%"
		)

		IF /I [%DOSEGMENTS%]==[true] (
			DIR /b /o:n "%TEMPLATE%\CanopyHeight_%SEG_CANOPYFILEIDENTIFIER%\CHM_*.dtm">layerlist.txt
			FOR /F %%i IN (layerlist.txt) DO CALL "%PROCESSINGHOME%\mergelayer" %%i 2 "%FINALPRODUCTHOME%\CanopyHeight_%SEG_CANOPYFILEIDENTIFIER%"
		)
	)
)

REM do the ground
IF /I "%MERGEBLOCKGROUND%"=="true" (
	IF /I "%DOGROUND%"=="true" (
		REM build a list of all the files in the folder
		DIR /b /o:n "%TEMPLATE%\BareGround_%GROUNDFILEIDENTIFIER%\BE_*.dtm">layerlist.txt

		REM step through the list of layers and merge each layer with the same name across the blocks
		FOR /F %%i IN (layerlist.txt) DO CALL "%PROCESSINGHOME%\mergelayer" %%i 2 "%FINALPRODUCTHOME%\BareGround_%GROUNDFILEIDENTIFIER%"
	)
)

REM do the intensity images...currently there is no way to merge image outputs
IF /I "%MERGEBLOCKINTENSITY%"=="true" (
	IF /I "%DOINTENSITY%"=="true" (
		REM build a list of all the files in the folder
		DIR /b /o:n "%TEMPLATE%\Intensity_%INTENSITYFILEIDENTIFIER%\*.bmp">layerlist.txt

		REM step through the list of layers and merge each layer with the same name across the blocks
		FOR /F %%i IN (layerlist.txt) DO CALL "%PROCESSINGHOME%\mergelayer" %%i 3 "%FINALPRODUCTHOME%\Intensity_%INTENSITYFILEIDENTIFIER%"
	)
)

REM do the topo metrics
REM IF DOTOPO or DOMULTITOPO are not SET to true, there will be a DOS error for the DIR command...not a problem but the error will show
REM in the command prompt window at the end of the processing. We have to live with this one because there is no good way to do a logical
REM OR in an IF statement in DOS.
IF /I "%MERGEBLOCKTOPOMETRICS%"=="true" (
	REM build a list of all the files in the folder
	DIR /b /o:n "%TEMPLATE%\TopoMetrics_%TOPOFILEIDENTIFIER%\*.asc">layerlist.txt

	REM step through the list of layers and merge each layer with the same name across the blocks
	FOR /F %%i IN (layerlist.txt) DO CALL "%PROCESSINGHOME%\mergelayer" %%i 1 "%FINALPRODUCTHOME%\TopoMetrics_%TOPOFILEIDENTIFIER%"
)

REM clean up
REM SET FILEIDENTIFIER=

CD %PROCESSINGHOME%


REM PAF 2017.01.12
REM I dont like how the Tile Logs are in there own directory and the block logs are not
CD %WORKINGDIRNAME%
SET LOGDIR=%WORKINGDIRNAME%\Logs
MD %LOGDIR%
MD %LOGDIR%\MERGELOGS
REM Move the Tile Logs
MOVE %WORKINGDIRNAME%\TILELOGS %LOGDIR%
REM Move the Block Logs
MOVE %WORKINGDIRNAME%\%RUNIDENTIFIER%_*.* %LOGDIR%\MERGELOGS
