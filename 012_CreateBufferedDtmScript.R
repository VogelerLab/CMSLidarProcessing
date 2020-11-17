#rm(list=ls())
#aa=Sys.time()

#Name:	004_CreateBufferedDtmScript.R
#Author:	PA Fekety
#Purpose:	Create a LAStools script, as a text file, to that creates buffered DTMs for
#		Lidar units in northern ID. 
#Date:	2017.01.10


#NOTE: the product of this script is a batch file that uses LAStools Las2Las.exe and Blast2Dem.exe

#2015.08.24	New
#2015.08.26	Change directory were the txt files are saved (in the sink() command)
#2015.08.28	Increased dtm tile size from 2km to 5km
#2015.08.29	renamed 'rasters' in file paths to 'raster'
#2015.09.14	Removed "CoeurdAlene" study area -it was a duplicate of Kamiah
#2016.02.05 Added Lidar collections for the Clearwater NF that flown in 2015.
#2016.08.11	Adding lidar collections from Idaho Lidar Consortium.
#		Changed ft.temp from ""D:\\Patrick\\N_ID_Imputation\\CMS\\LidarMetrics" to ""D:\\Patrick\\CMS\\LidarMetrics"
#2016.08.16	Moved scripts from CMS\N_ID_Imputation\Scripts to CMS\LidarData\Scripts
#		Renamed as 04_XXX.R (formally 03_XXX.R)
#2016.08.17	Added class 8 (model key point) to points that are used in the DTM construction
#2016.08.19	renamed script to 06_CreateBufferedDtmScript.R (formerlly was 04_CreateBufferedDtmScript.R)
#2016.09.07	Reran to have consistent naming system after updating FUSION file structure.
#2016.09.07	Reran to have consistent naming system after updating FUSION file structure.
#		Renamed 'D:\Patrick\CMS\LidarMetrics\epsg5071\' as 'D:\Patrick\CMS\LidarMetrics\epsg5071_Trans\'
#2016.09.15	Added BoiseRiver2015, BorahScarp2005, ColumbiaRiverTreaty_D5_UTM11_ID, ReynoldsCreek2009, SmithCreek
#2016.09.19	Added SouthMountain2007
#2016.09.28	Added ReynoldsCreek2007
#2017.01.10	New, based on D:\Patrick\CMS\LidarData\Scripts\06_CreateBufferedDtmScript.R
#		which was for the LTK processor




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

#inputs: 
#	studyArea - (char) name of the LiDAR project area
#	inputDirectory - (char) file path for LiDAR 
#	HOMEFOLDER - (char) HOMEFOLDER for FUSION run
#outputs:
#	A batch file in CMD that will call LAStools and create a DTM
createDtmBatchFile <- function(studyArea, inputDirectory, HOMEFOLDER){
	
	#FUSION processing home
	PROCESSINGHOME <- paste0(HOMEFOLDER, 'Processing\\')
	DTMSPEC <-  paste0(HOMEFOLDER, 'Deliverables\\DTM\\')
	
	
	#create a vector of LAZ and LAS files in the inputDirectory
	LAZs <- dir(inputDirectory)[grep(pattern="[.]laz$", x=dir(inputDirectory))]
	LASs <- dir(inputDirectory)[grep(pattern="[.]las$", x=dir(inputDirectory))]
	LidarPoints <- c(LAZs, LASs)
	
	#Build file header
	sink(file = paste0(PROCESSINGHOME, "CreateBufferedDtm_", studyArea, ".bat")) #opens the diversion
	cat(paste0(":: Batch file to create Buffered DTMs for ", studyArea))
	cat("\n")
	cat("::")
	cat("\n")
	cat(paste0(":: This batch file was created by 004_CreateBufferedDtmScript.R on ", date()))
	cat("\n")
	cat("::")
	cat("\n")
	cat("\n")
	cat("PATH=%PATH%;N:\\Lastools\\bin")
	cat("\n")
	cat("\n")
	
	
	cat(":: create a temp directory to hold buffered LAZ files")
	cat("\n")
	fp.temp <- paste0(HOMEFOLDER, "temp")
	cat(paste0("MKDIR ", fp.temp))
	cat("\n")
	#for the project level LAZ
	fp.temp.project <- paste0(fp.temp, "\\PROJECT")
	cat(paste0("MKDIR ", fp.temp.project))
	cat("\n")
	#For the tiles
	fp.temp.tile <- paste0(fp.temp, "\\TILE")
	cat(paste0("MKDIR ", fp.temp.tile))
	cat("\n")
	
	
	cat(paste0("las2las -i ", inputDirectory, "*.laz -merged -o ", fp.temp.project, "\\Project.LAZ -keep_class 2 8 -v"))
	cat("\n")
	cat("\n")
	cat(":: use LAStile to create small DTMs with buffers")
	cat("\n")
	cat(paste0("lastile -i ", fp.temp.project, "\\Project.LAZ -odir ", fp.temp.tile, " -tile_size 5000 -buffer 60 -olaz -v"))
	cat("\n")
	
	cat(paste0("blast2dem -i ", fp.temp.tile, "\\*.laz -odir ", DTMSPEC, " -odtm -v -step 1"))
	cat("\n")
	cat("\n")
	
	cat("::Delete temp directory, and its contents")
	cat("\n")
	cat(paste("RMDIR ", fp.temp, "/S /Q"))
	cat("\n")
	
	sink(file=NULL) #closes the diversion
}


runBufferedDtm <- function(studyArea, DIR_BASE, DIR_LIDAR){
	
	print(paste0("Creating ground DTM for ", studyArea));flush.console()
	
	HOMEFOLDER <- paste0(DIR_BASE, studyArea, "\\")
	
	#Directory where the LAS files are stored
	#DIR_LIDAR=paste0("D:\\Patrick\\CMS\\LidarData\\epsg5071\\", studyArea, "\\")
	
	#Create the batch file
	createDtmBatchFile(studyArea=studyArea, inputDirectory=DIR_LIDAR, HOMEFOLDER=HOMEFOLDER)
	
	#Run the batch file
	shell(paste0(HOMEFOLDER, "Processing\\CreateBufferedDtm_", studyArea, ".bat"))
}




#--------------------------------
#--------------------------------
#Create and RUN Batch Files!!
#--------------------------------
#--------------------------------

#Comment out after running

#runBufferedDtm(studyArea="DCEF2011")




