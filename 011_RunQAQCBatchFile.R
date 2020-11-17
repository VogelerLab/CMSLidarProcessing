#rm(list=ls())
#aa=Sys.time()

#Name:	011_RunQAQCBatchFile.R
#Author:	PA Fekety
#Purpose:	Create a batch file that runs QAQC
#		Create a text file of the las files for a study area
#		run QAQC.bat
#Date:	2017.01.10


#2016.09.07	New.
#		Created because I reran other scripts to have consistent naming system after updating FUSION file structure.
#		Renamed 'D:\Patrick\CMS\LidarMetrics\epsg5071\' as 'D:\Patrick\CMS\LidarMetrics\epsg5071_Trans\'
#		Used to be run from CMD windown using a text file
#2016.09.16	Added BoiseRiver2015, BorahScarp2005, ColumbiaRiverTreaty_D5_UTM11_ID, ReynoldsCreek2009, SmithCreek
#2016.09.07	Reran to have consistent naming system after updating FUSION file structure.
#2016.09.19	Added SouthMountain2007
#2016.09.28	Added ReynoldsCreek2007
#2017.01.10	New, based on D:\Patrick\CMS\LidarData\Scripts\05_BuildFusionFileStructure.R 
#		which was for the LTK processor
#2017.01.15	Changed values in catalog command from  /firstdensity:900,4,20 /density:900,4,20 to /firstdensity:900,1,8 /density:900,2,16
#2018.02.20	Input lidar files are now LAZs; RunQaQc() now requires "DIR_BASE" and "DIR_LIDAR" parameters; 
#			createQaQcBatchFile() requires "PROCESSINGHOME" parameter
#2018.02.21	Removed /index switch from the catalog call. Reading from LAZ isn't that slow.
#		the index files are larger than the LAZs



#--------------------------------
#--------------------------------
#Load Packages, Define Variables
#--------------------------------
#--------------------------------



 

#--------------------------------
#--------------------------------
#Define Functions
#--------------------------------
#--------------------------------



#Create the QAQC batch file
createQaQcBatchFile <- function(DIR_BASE, studyArea, PROCESSINGHOME){
	
	#open the diversion
	sink(paste0(PROCESSINGHOME, "runQAQC.bat"))

	#Write Header info
	cat("REM File Name: ")
	cat(paste0(PROCESSINGHOME, "runQAQC.bat"))

	cat("\n")
	cat("REM created on: ")
	cat(date())
	cat("\n")
	cat("\n")

	cat('PATH=%PATH%;C:\\FUSION')
	cat('\n')
	cat('\n')	
	cat('rem use the FUSION catalog program to produce reports useful for assessing overall acquisition quality')
	cat('\n')
	cat('rem also produces FUSION indes files so the data are ready for viewing with FUSION')
	cat('\n')
	cat('\n')
	cat('rem when UNITS is FEET:')
	cat('\n')
	cat('rem intensity image uses full range of 8-bit values and a pixel size that is 25 by 25 units (625 square units)')
	cat('\n')
	cat('rem pulse density is evaluated using a 300 by 300 unit cell (90000 square units) with an acceptable pulse density of 0.37 pulses/ft^2 (about 4 pulses/m^2)')
	cat('\n')
	cat('rem and a maximum density of 2 pulses/ft^2 (about 21 pulses/m^2)')
	cat('\n')
	cat('rem return density is evaluated using a 100 by 100 unit cell (10000 square units) with an acceptable return density of 0.37 returns/ft^2 (about 4 returns/m^2)')
	cat('\n')
	cat('rem and a maximum density of 2 returns/ft^2 (about 21 returns/m^2)')
	cat('\n')
	cat('rem the /rawcounts option produces detailed pulse and return density rasters for use with LTKProcessor')
	cat('\n')
	cat('\n')	
	cat('rem when UNITS is METERS:')
	cat('\n')
	cat('rem intensity image uses full range of 8-bit values and a pixel size that is 7.5 by 7.5 meters (56.25 sq m)')
	cat('\n')
	cat('rem pulse density is evaluated using a 100 by 100 unit cell (10000 square units) with an acceptable pulse density of 4 pulses/m^2')
	cat('\n')
	cat('rem and a maximum density of 21 pulses/m^2')
	cat('\n')
	cat('rem return density is evaluated using a 100 by 100 unit cell (10000 square units) with an acceptable pulse density of 4 pulses/m^2')
	cat('\n')
	cat('rem and a maximum density of 21 pulses/m^2')
	cat('\n')
	cat('rem the /rawcounts option produces detailed pulse and return density rasters for use with LTKProcessor')
	cat('\n')
	cat('\n')
	cat('rem Catalog /rawcounts /coverage /intensity:625,0,255 /firstdensity:90000,.37,2 /density:90000,.37,2 filelist.txt %PRODUCTHOME%\\QAQC\\QAQC.csv')
	cat('\n')
	cat('\n')
	
	cat('@echo on')
	cat('\n')
	cat(paste0('Catalog /rawcounts /coverage /intensity:900,0,255 /firstdensity:900,1,8 /density:900,2,16 ', PROCESSINGHOME, 'filelist.txt ', DIR_BASE, studyArea, '\\Products\\QAQC\\QAQC.csv'))
	cat('\n')
	cat('@echo off')
	cat('\n')
	#close the diversion
	sink()

}

#Purpose:
#	Create a list of LAS files
#inputs: 
#	DIR_LAS - (char) file path for LiDAR 
#	PROCESSINGHOME - (char) file path where the filelist will be saved
#outputs:
#	A batch file in CMD that will call LAStools and create a DTM
createLasFileList <- function(DIR_LIDAR, PROCESSINGHOME){
	
	#create a vector of LAZ and LAS files in the inputDirectory
	LASs <- dir(DIR_LIDAR, full.names=TRUE, pattern="[.]laz$")
	
	#Create the filelist.txt
	sink(file = paste0(PROCESSINGHOME, "filelist.txt")) #opens the diversion
	for (LAS in LASs){
		cat(LAS)
		cat("\n")
	}
	
	sink(file=NULL) #closes the diversion
}



#Purpose:
#	run QAQC
#inputs: 
#	studyArea - (char) Name of the study area
#outputs:
#	Running of QAQC.bat

RunQaQc <- function(studyArea, DIR_BASE, DIR_LIDAR){

	print(paste0("Running QAQC.bat for ", studyArea)); flush.console()
	#DIR_BASE <- "D:\\Patrick\\CMS\\LidarMetrics\\epsg5071_Trans\\FusionAP\\"
	
	#Processing directory
	PROCESSINGHOME <- paste0(DIR_BASE, studyArea, "\\Processing\\")
	
	#Directory where the LAS files are stored
	#DIR_LIDAR <- paste0("D:\\Patrick\\CMS\\LidarData\\epsg5071\\", studyArea, "\\")
	
	#Create filelist.txt
	createLasFileList(DIR_LIDAR, PROCESSINGHOME)
	#Create QAQC.bat
	createQaQcBatchFile(DIR_BASE=DIR_BASE, studyArea=studyArea, PROCESSINGHOME=PROCESSINGHOME)
	
	#Run QAQC.bat
	shell(paste0(PROCESSINGHOME, "runQAQC.bat"))
	
}





#--------------------------------
#--------------------------------
#Run Batch scripts
#--------------------------------
#--------------------------------

#RunQaQc(studyArea="DCEF2011")

