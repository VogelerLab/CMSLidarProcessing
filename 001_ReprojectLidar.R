rm(list=ls())
aa=Sys.time()

#Name:	001_ReprojectLidar.R
#Purpose:	To (re)project lidar from native projection (typically NAD 83 UTM 11N) to 
#		NAD_1983 Albers Equal Area (EPSG 5071) to match LandTrendr projection.
#		Initially, just project northern half of Idaho.
#Date:	2015.08.05

#2017.09.08	Added ColvilleNFEast2015 and ColvilleNFWest2015
#2017.03.01	Reran: ISUPocatello2015, CamasNWR, LemhiRiver2011
#		LAStools can't project from ID state plane to ESPG 5071 in one command
#2017.01.18	projectLidarBatchFile() no longer relies on WD;
#		Batch file is now saved to the output directory
#		Added Colville NF units (3 in total)
#2016.09.27	Added ReynoldsCreek2007
#2016.09.19	Added SouthMountain2007
#2016.09.15	Added BoiseRiver2015, BorahScarp2005, ColumbiaRiverTreaty_D5_UTM11_ID, ReynoldsCreek2009, SmithCreek
#2016.08.16	Moved scripts from CMS\N_ID_Imputation\Scripts to CMS\LidarData\Scripts
#2016.08.11	Adding lidar collections from Idaho Lidar Consortium. I did my best to determine which epsg code
#		to use for CamasNWR, ISUPocatello, and Lemhi2011
#2016.02.05 Added Lidar collections for the Clearwater NF that flown in 2015.
#2015.09.18	Reran PayetteA6 because the CRS was not defined in the LAS header.
#2015.09.14	Reran PayetteA2, A3, A4, and A6 because They are now being treated as their 
#		own study area. Removed "CoeurdAlene" study area -it was a duplicate of Kamiah.
#2015.08.27	Modified batch script to reproject into LAS files, translate the lidar by 
#		a false easting (3000000 meters) as a LAS file, delete the non-translated LAS file
#2015.08.05	New

#After much thought, I think that it will be easiest to use this R script to create 
#CMD batch files that will call LAStools. 

#LandTrendr data: 
#	central meridian = -96
#	standard parallel 1 = 29.5
#	standard parallel 2 = 45.5
#	latitude of orgin = 23
#	datam = D_North_America_1983

#This is equivalent to  EPSG 5071 (http://epsg.io/5071)



WD <- "G:\\FR\\MFalkows-VMStorage\\Patrick\\CMS\\LidarData\\"
setwd(WD)

#--------------------------------
#--------------------------------
#Define Functions
#--------------------------------
#--------------------------------

#works
#path=%path%;f:\lastools\bin
#:native UTM coordinates
#lasinfo -i -i D:/Patrick/LidarData/Idaho/PREF2002/Points/Classified/MCC/pref_mcc3_04.laz
#
#:project into AEA
#las2las -i D:/Patrick/LidarData/Idaho/PREF2002/Points/Classified/MCC/pref_mcc3_04.laz -o D:/Patrick/CMS/N_ID_Imputation/LidarData/epsg5071/PREF2002/pref_mcc3_04_proj.las -utm 11T -target_epsg 5071 -v
#lasinfo -i D:/Patrick/CMS/N_ID_Imputation/LidarData/epsg5071/PREF2002/pref_mcc3_04_proj.las
#
#:translate projected lidar by 3,000,000 units (meters?)
#las2las -i D:/Patrick/CMS/N_ID_Imputation/LidarData/epsg5071/PREF2002/pref_mcc3_04_proj.las -o D:/Patrick/CMS/N_ID_Imputation/LidarData/epsg5071/PREF2002/pref_mcc3_04_Trans3000000.las -v -translate_x 3000000
#lasinfo -i D:/Patrick/CMS/N_ID_Imputation/LidarData/epsg5071/PREF2002/pref_mcc3_04_Trans3000000.las


#inputs: 
#	studyArea - (char) name of the LiDAR project area
#	inputDirectory - (char) file path for LiDAR to be reprojected
#	outputDirectory - (char) file path where the reprojected LiDAR will be saved
#	inputRefSys - (char) spatial reference code for the LiDAR before the reprojection
#	outputRefSys - (char) the target spatial reference system
#outputs:
#	A batch file in CMD that will call LAStools and reproject LiDAR
projectLidarBatchFile <- function(studyArea, inputDirectory, outputDirectory, inputRefSys=NULL , outputRefSys){
	
	#determine in the inputRefSys was specified
	if (!is.null(inputRefSys)) {
		inputRefSys = paste0("-", inputRefSys, " ")
	}
	
	#create a vector of LAZ and LAS files in the inputDirectory
	LAZs <- dir(inputDirectory)[grep(pattern="[.]laz$", x=dir(inputDirectory))]
	LASs <- dir(inputDirectory)[grep(pattern="[.]las$", x=dir(inputDirectory))]
	LidarPoints <- c(LAZs, LASs)
	
	#Create the outputDirectory, if it doesn't already exisit
	if(!file.exists(outputDirectory)) {
		dir.create(outputDirectory, showWarnings = FALSE)
	}
	
	
	#Build file header
	sink(file = paste0(outputDirectory, "_001_Project", studyArea, ".bat")) #opens the diversion
	cat(paste0(":: Batch file to reproject ", studyArea, " lidar from ", inputRefSys, " to ", outputRefSys ))
	cat("\n")
	cat("::")
	cat("\n")
	cat(paste0(":: This batch file was created by 001_ReprojectLidar.R on ", date()))
	cat("\n")
	cat("::")
	cat("\n")
	cat("\n")
	cat("PATH=%PATH%;N:\\Lastools\\bin")
	cat("\n")
	cat("\n")
	
	#Project all the LiDAR data, and convert to LAS files
	for (i in 1:length(LidarPoints)){
		cat(paste0("las2las -i ", inputDirectory, LidarPoints[i], " -odir ", outputDirectory, " -olaz ", inputRefSys, "-target_", outputRefSys, " -v"))
		cat("\n")
	}
	
	cat("\n")
	#Translate the reprojected LAS files by 3,000,000 meters
	for (i in 1:length(LidarPoints)){
		cat(paste0("las2las -i ", outputDirectory, strsplit(LidarPoints[i], split="[.]")[[1]][1], ".laz -o ", outputDirectory, strsplit(LidarPoints[i], split="[.]")[[1]][1], "_Trans3000000.laz -v -translate_x 3000000"))
		cat("\n")
	}		
	
	cat("\n")
	#delete the untranslated files
	for (i in 1:length(LidarPoints)){
		cat(paste0("DEL ", outputDirectory, strsplit(LidarPoints[i], split="[.]")[[1]][1], ".laz"))
		cat("\n")
	}
	
	sink(file=NULL) #closes the diversion
}


#Purpose:
#	Some lidar units (e.g. thoses in ID state Plane East (epsg 2241) need to first be projected to UTM, then to epsg 5071
#inputs: 
#	studyArea - (char) name of the LiDAR project area
#	inputDirectory - (char) file path for LiDAR to be reprojected
#	outputDirectory - (char) file path where the reprojected LiDAR will be saved
#	inputRefSys - (char) spatial reference code for the LiDAR before the reprojection
#	outputRefSys - (char) the target spatial reference system
#outputs:
#	A batch file in CMD that will call LAStools and reproject LiDAR to UTM Only
projectLidarToUtmBatchFile <- function(studyArea, inputDirectory, outputDirectory, inputRefSys=NULL , outputRefSys){
	
	#determine in the inputRefSys was specified
	if (!is.null(inputRefSys)) {
		inputRefSys = paste0("-", inputRefSys, " ")
	}
	
	#create a vector of LAZ and LAS files in the inputDirectory
	LAZs <- dir(inputDirectory)[grep(pattern="[.]laz$", x=dir(inputDirectory))]
	LASs <- dir(inputDirectory)[grep(pattern="[.]las$", x=dir(inputDirectory))]
	LidarPoints <- c(LAZs, LASs)
	
	#Create the outputDirectory, if it doesn't already exisit
	if(!file.exists(outputDirectory)) {
		dir.create(outputDirectory, showWarnings = FALSE)
	}
	
	
	#Build file header
	sink(file = paste0(outputDirectory, "_000_Project", studyArea, ".bat")) #opens the diversion
	cat(paste0(":: Batch file to reproject ", studyArea, " lidar from ", inputRefSys, " to ", outputRefSys ))
	cat("\n")
	cat("::")
	cat("\n")
	cat(paste0(":: This batch file was created by 001_ReprojectLidar.R on ", date()))
	cat("\n")
	cat("::")
	cat("\n")
	cat("\n")
	cat("PATH=%PATH%;N:\\Lastools\\bin")
	cat("\n")
	cat("\n")
	
	#Project all the LiDAR data, and convert to LAS files
	for (i in 1:length(LidarPoints)){
		cat(paste0("las2las -i ", inputDirectory, LidarPoints[i], " -odir ", outputDirectory, " -olas ", inputRefSys, "-target_", outputRefSys, " -v"))
		cat("\n")
	}
	
	cat("\n")

	sink(file=NULL) #closes the diversion
}



printCRS <- function(){
print(paste("
# Common Projections #
## UTM Projections
#ESPG:26910: NAD83 / UTM zone 10N
#ESPG:26911: NAD83 / UTM zone 11N
#ESPG:26912: NAD83 / UTM zone 12N
#ESPG:6339: NAD83(2011) / UTM zone 10N
#ESPG:6340: NAD83(2011) / UTM zone 11N
#ESPG:6341: NAD83(2011) / UTM zone 12N
#ESPG:3740: NAD83(HARN) / UTM zone 10N
#ESPG:3741: NAD83(HARN) / UTM zone 11N
#ESPG:3742: NAD83(HARN) / UTM zone 12N
#ESPG:3717: NAD83(NSRS2007) / UTM zone 10N
#ESPG:3718: NAD83(NSRS2007) / UTM zone 11N
#ESPG:3719: NAD83(NSRS2007) / UTM zone 12N
#ESPG:3157: NAD83(CSRS) / UTM zone 10N
#ESPG:2955: NAD83(CSRS) / UTM zone 11N
#ESPG:2956: NAD83(CSRS) / UTM zone 12N
#EPSG:32610: WGS 84 / UTM zone 10N
#EPSG:32611: WGS 84 / UTM zone 11N
#EPSG:32612: WGS 84 / UTM zone 12N

## State Plane Projections
#ESRI:102268: NAD 1983 HARN StatePlane Idaho East FIPS 1101
#ESRI:102269: NAD 1983 HARN StatePlane Idaho Central FIPS 1102
#ESRI:102270: NAD 1983 HARN StatePlane Idaho West FIPS 1103
#ESRI:102668: NAD 1983 StatePlane Idaho East FIPS 1101 Feet
#ESRI:102669: NAD 1983 StatePlane Idaho Central FIPS 1102 Feet
#ESRI:102670: NAD 1983 StatePlane Idaho West FIPS 1103 Feet
#EPSG:2241: NAD83 / Idaho East (ftUS)
#EPSG:2242: NAD83 / Idaho Central (ftUS)
#EPSG:2243: NAD83 / Idaho West (ftUS)
#EPSG:2787: NAD83(HARN) / Idaho East
#EPSG:2788: NAD83(HARN) / Idaho Central
#EPSG:2789: NAD83(HARN) / Idaho West
#EPSG:2886: NAD83(HARN) / Idaho East (ftUS)
#EPSG:2887: NAD83(HARN) / Idaho Central (ftUS)
#EPSG:2888: NAD83(HARN) / Idaho West (ftUS)
#ESRI:102348: NAD 1983 HARN StatePlane Washington North FIPS 4601
#ESRI:102349: NAD 1983 HARN StatePlane Washington South FIPS 4602
#ESRI:102748: NAD 1983 StatePlane Washington North FIPS 4601 Feet
#ESRI:102749: NAD 1983 StatePlane Washington South FIPS 4602 Feet
#ESRI:102218: NAD 1983 USFS R6 Albers (Meters)
"))
}


#--------------------------------
#--------------------------------
#Create Batch Files!!
#--------------------------------
#--------------------------------

###Bannock
##projectLidarBatchFile(studyArea="Bannock", 
##	inputDirectory="D:\\Patrick\\LidarData\\Idaho\\Bannock\\Points\\Classified\\LASground\\", 
##	outputDirectory="D:\\Patrick\\CMS\\N_ID_Imputation\\LidarData\\epsg5071\\Bannock\\", 
##	inputRefSys="utm 11T", 
##	outputRefSys = "epsg 5071"
##)
##
##
###ClearCreek
##projectLidarBatchFile(studyArea="ClearCreek", 
##	inputDirectory="D:\\Patrick\\LidarData\\Idaho\\ClearCreek\\Points\\LAZ\\", 
##	outputDirectory="D:\\Patrick\\CMS\\N_ID_Imputation\\LidarData\\epsg5071\\ClearCreek\\", 
##	inputRefSys="utm 11T", 
##	outputRefSys = "epsg 5071"
##)
##
##
###CoeurdAlene - this is the same data as Kamiah
###projectLidarBatchFile(studyArea="CoeurdAlene", 
###	inputDirectory="D:\\Patrick\\LidarData\\Idaho\\CoeurdAlene\\lidarpc_46116b1_cdatribe\\", 
###	outputDirectory="D:\\Patrick\\CMS\\N_ID_Imputation\\LidarData\\epsg5071\\CoeurdAlene\\", 
###	inputRefSys="utm 11T", 
###	outputRefSys = "epsg 5071"
###)
##
##
###CorralHogMeadowCreekPotlatchRiver
##projectLidarBatchFile(studyArea="CorralHogMeadowCreekPotlatchRiver", 
##	inputDirectory="D:\\Patrick\\LidarData\\Idaho\\CorralHogMeadowCreekPotlatchRiver\\Points\\LAZ\\", 
##	outputDirectory="D:\\Patrick\\CMS\\N_ID_Imputation\\LidarData\\epsg5071\\CorralHogMeadowCreekPotlatchRiver\\", 
##	inputRefSys="utm 11T", 
##	outputRefSys = "epsg 5071"
##)
##
##
##
###CrookedRiver
##projectLidarBatchFile(studyArea="CrookedRiver", 
##	inputDirectory="D:\\Patrick\\LidarData\\Idaho\\CrookedRiver\\Points\\LAZ\\", 
##	outputDirectory="D:\\Patrick\\CMS\\N_ID_Imputation\\LidarData\\epsg5071\\CrookedRiver\\", 
##	inputRefSys="utm 11T", 
##	outputRefSys = "epsg 5071"
##)
##
##
###DCEF2011
##projectLidarBatchFile(studyArea="DCEF2011", 
##	inputDirectory="D:\\Patrick\\LidarData\\Idaho\\DCEF2011\\Points\\LAZ\\", 
##	outputDirectory="D:\\Patrick\\CMS\\N_ID_Imputation\\LidarData\\epsg5071\\DCEF2011\\", 
##	inputRefSys="utm 11T", 
##	outputRefSys = "epsg 5071"
##)
##
##
###DutchOven
##projectLidarBatchFile(studyArea="DutchOven", 
##	inputDirectory="D:\\Patrick\\LidarData\\Idaho\\DutchOven\\Points\\LAZ\\", 
##	outputDirectory="D:\\Patrick\\CMS\\N_ID_Imputation\\LidarData\\epsg5071\\DutchOven\\", 
##	inputRefSys="utm 11T", 
##	outputRefSys = "epsg 5071"
##)
##
##
###ElkCity
##projectLidarBatchFile(studyArea="ElkCity", 
##	inputDirectory="D:\\Patrick\\LidarData\\Idaho\\ElkCity\\Points\\Classified\\LASground\\", 
##	outputDirectory="D:\\Patrick\\CMS\\N_ID_Imputation\\LidarData\\epsg5071\\ElkCity\\", 
##	inputRefSys="utm 11T", 
##	outputRefSys = "epsg 5071"
##)
##
##
###EmeraldCreek
##projectLidarBatchFile(studyArea="EmeraldCreek", 
##	inputDirectory="D:\\Patrick\\LidarData\\Idaho\\EmeraldCreek\\Points\\Classified\\MCC\\", 
##	outputDirectory="D:\\Patrick\\CMS\\N_ID_Imputation\\LidarData\\epsg5071\\EmeraldCreek\\", 
##	inputRefSys="utm 11T", 
##	outputRefSys = "epsg 5071"
##)
##
##
##
###Fernan
##projectLidarBatchFile(studyArea="Fernan", 
##	inputDirectory="D:\\Patrick\\LidarData\\Idaho\\Fernan\\Points\\LAZ\\", 
##	outputDirectory="D:\\Patrick\\CMS\\N_ID_Imputation\\LidarData\\epsg5071\\Fernan\\", 
##	inputRefSys="utm 11T", 
##	outputRefSys = "epsg 5071"
##)
##
###FrenchCreekPreacherNorthForkFront
##projectLidarBatchFile(studyArea="FrenchCreekPreacherNorthForkFront", 
##	inputDirectory="D:\\Patrick\\LidarData\\Idaho\\FrenchCreekPreacherNorthForkFront\\Points\\LAZ\\", 
##	outputDirectory="D:\\Patrick\\CMS\\N_ID_Imputation\\LidarData\\epsg5071\\FrenchCreekPreacherNorthForkFront\\", 
##	inputRefSys="utm 11T", 
##	outputRefSys = "epsg 5071"
##)
##
###JackWaite
##projectLidarBatchFile(studyArea="JackWaite", 
##	inputDirectory="D:\\Patrick\\LidarData\\Idaho\\JackWaite\\Points\\Classified\\LASground\\", 
##	outputDirectory="D:\\Patrick\\CMS\\N_ID_Imputation\\LidarData\\epsg5071\\JackWaite\\", 
##	inputRefSys="survey_feet -elevation_feet", #projection has been defined, but the inputs were in feet
##	outputRefSys = "epsg 5071 -target_meter -target_elevation_meter" #ensure output are  also in meters
##)
##
###Kamiah
##projectLidarBatchFile(studyArea="Kamiah", 
##	inputDirectory="D:\\Patrick\\LidarData\\Idaho\\Kamiah\\lidarpc_46116b1_cdatribe\\", 
##	outputDirectory="D:\\Patrick\\CMS\\N_ID_Imputation\\LidarData\\epsg5071\\Kamiah\\", 
##	inputRefSys="utm 11T", 
##	outputRefSys = "epsg 5071"
##)
##
###LaundryChinaOsier
##projectLidarBatchFile(studyArea="LaundryChinaOsier", 
##	inputDirectory="D:\\Patrick\\LidarData\\Idaho\\LaundryChinaOsier\\Points\\LAZ\\", 
##	outputDirectory="D:\\Patrick\\CMS\\N_ID_Imputation\\LidarData\\epsg5071\\LaundryChinaOsier\\", 
##	inputRefSys="utm 11T", 
##	outputRefSys = "epsg 5071"
##)
##
###LoloCreekElDoradoCreek
##projectLidarBatchFile(studyArea="LoloCreekElDoradoCreek", 
##	inputDirectory="D:\\Patrick\\LidarData\\Idaho\\LoloCreekElDoradoCreek\\Points\\LAZ\\", 
##	outputDirectory="D:\\Patrick\\CMS\\N_ID_Imputation\\LidarData\\epsg5071\\LoloCreekElDoradoCreek\\", 
##	inputRefSys="utm 11T", 
##	outputRefSys = "epsg 5071"
##)
##
##
##
###MillCreekHungryRidge
##projectLidarBatchFile(studyArea="MillCreekHungryRidge", 
##	inputDirectory="D:\\Patrick\\LidarData\\Idaho\\MillCreekHungryRidge\\Points\\LAZ\\", 
##	outputDirectory="D:\\Patrick\\CMS\\N_ID_Imputation\\LidarData\\epsg5071\\MillCreekHungryRidge\\", 
##	inputRefSys="utm 11T", 
##	outputRefSys = "epsg 5071"
##)
##
###MoscowMtn2003
##projectLidarBatchFile(studyArea="MoscowMtn2003", 
##	inputDirectory="D:\\Patrick\\LidarData\\Idaho\\MoscowMtn2003\\Points\\Classified\\MCC\\", 
##	outputDirectory="D:\\Patrick\\CMS\\N_ID_Imputation\\LidarData\\epsg5071\\MoscowMtn2003\\", 
##	inputRefSys="utm 11T", 
##	outputRefSys = "epsg 5071"
##)
##
###MoscowMtn2007
##projectLidarBatchFile(studyArea="MoscowMtn2007", 
##	inputDirectory="D:\\Patrick\\LidarData\\Idaho\\MoscowMtn2007\\Points\\LAZ\\", 
##	outputDirectory="D:\\Patrick\\CMS\\N_ID_Imputation\\LidarData\\epsg5071\\MoscowMtn2007\\", 
##	inputRefSys="utm 11T", #ref sys has already been defined
##	outputRefSys = "epsg 5071"
##)
##
###MoscowMtn2009
##projectLidarBatchFile(studyArea="MoscowMtn2009", 
##	inputDirectory="D:\\Patrick\\LidarData\\Idaho\\MoscowMtn2009\\Points\\Classified\\MCC\\", 
##	outputDirectory="D:\\Patrick\\CMS\\N_ID_Imputation\\LidarData\\epsg5071\\MoscowMtn2009\\", 
##	inputRefSys="utm 11T", 
##	outputRefSys = "epsg 5071"
##)
##
###Musselshell
##projectLidarBatchFile(studyArea="Musselshell", 
##	inputDirectory="D:\\Patrick\\LidarData\\Idaho\\Musselshell\\Points\\LAZ\\", 
##	outputDirectory="D:\\Patrick\\CMS\\N_ID_Imputation\\LidarData\\epsg5071\\Musselshell\\", 
##	inputRefSys="utm 11T", 
##	outputRefSys = "epsg 5071"
##)
##
###NezPerce
##projectLidarBatchFile(studyArea="NezPerce", 
##	inputDirectory="D:\\Patrick\\LidarData\\Idaho\\NezPerce\\Points\\Classified\\MCC\\", 
##	outputDirectory="D:\\Patrick\\CMS\\N_ID_Imputation\\LidarData\\epsg5071\\NezPerce\\", 
##	inputRefSys="utm 11T", 
##	outputRefSys = "epsg 5071"
##)
##
###Payette A2
##projectLidarBatchFile(studyArea="PayetteA2", 
##	inputDirectory="D:\\Patrick\\LidarData\\Idaho\\PayetteA2\\Points\\LAZ\\", 
##	outputDirectory="D:\\Patrick\\CMS\\N_ID_Imputation\\LidarData\\epsg5071\\PayetteA2\\", 
##	inputRefSys=NULL, #ref system already defined (NAD 1983 State Plane FIPS 1103 Feet)
##	outputRefSys = "epsg 5071"
##)
##
###Payette A3
##projectLidarBatchFile(studyArea="PayetteA3", 
##	inputDirectory="D:\\Patrick\\LidarData\\Idaho\\PayetteA3\\Points\\LAZ\\", 
##	outputDirectory="D:\\Patrick\\CMS\\N_ID_Imputation\\LidarData\\epsg5071\\PayetteA3\\", 
##	inputRefSys=NULL, #ref system already defined (NAD 1983 State Plane FIPS 1103 Feet)
##	outputRefSys = "epsg 5071"
##)
##
###Payette A4
##projectLidarBatchFile(studyArea="PayetteA4", 
##	inputDirectory="D:\\Patrick\\LidarData\\Idaho\\PayetteA4\\Points\\LAZ\\", 
##	outputDirectory="D:\\Patrick\\CMS\\N_ID_Imputation\\LidarData\\epsg5071\\PayetteA4\\", 
##	inputRefSys=NULL, #ref system already defined (NAD 1983 State Plane FIPS 1103 Feet)
##	outputRefSys = "epsg 5071"
##)
##
###Payette A6
##projectLidarBatchFile(studyArea="PayetteA6", 
##	inputDirectory="D:\\Patrick\\LidarData\\Idaho\\PayetteA6\\Points\\LAZ\\", 
##	outputDirectory="D:\\Patrick\\CMS\\N_ID_Imputation\\LidarData\\epsg5071\\PayetteA6\\", 
##	inputRefSys="sp83 ID_W -feet -elevation_feet", #ref system already defined (NAD 1983 State Plane FIPS 1103 Feet)
##	outputRefSys = "epsg 5071"
##)
##
###Potlatch
##projectLidarBatchFile(studyArea="Potlatch", 
##	inputDirectory="D:\\Patrick\\LidarData\\Idaho\\Potlatch\\Points\\LAZ\\", 
##	outputDirectory="D:\\Patrick\\CMS\\N_ID_Imputation\\LidarData\\epsg5071\\Potlatch\\", 
##	inputRefSys="utm 11T", 
##	outputRefSys = "epsg 5071"
##)
##
###Powell
##projectLidarBatchFile(studyArea="Powell", 
##	inputDirectory="D:\\Patrick\\LidarData\\Idaho\\Powell\\Points\\LAZ\\", 
##	outputDirectory="D:\\Patrick\\CMS\\N_ID_Imputation\\LidarData\\epsg5071\\Powell\\", 
##	inputRefSys="utm 11T", 
##	outputRefSys = "epsg 5071"
##)
##
###PREF2002
##projectLidarBatchFile(studyArea="PREF2002", 
##	inputDirectory="D:\\Patrick\\LidarData\\Idaho\\PREF2002\\Points\\Classified\\MCC\\", 
##	outputDirectory="D:\\Patrick\\CMS\\N_ID_Imputation\\LidarData\\epsg5071\\PREF2002\\", 
##	inputRefSys="utm 11T", 
##	outputRefSys = "epsg 5071"
##)
##
###PREF2011
##projectLidarBatchFile(studyArea="PREF2011", 
##	inputDirectory="D:\\Patrick\\LidarData\\Idaho\\PREF2011\\Points\\LAZ\\", 
##	outputDirectory="D:\\Patrick\\CMS\\N_ID_Imputation\\LidarData\\epsg5071\\PREF2011\\", 
##	inputRefSys="utm 11T", 
##	outputRefSys = "epsg 5071"
##)
##
###SelwayRiverElkCreek
##projectLidarBatchFile(studyArea="SelwayRiverElkCreek", 
##	inputDirectory="D:\\Patrick\\LidarData\\Idaho\\SelwayRiverElkCreek\\Points\\LAZ\\", 
##	outputDirectory="D:\\Patrick\\CMS\\N_ID_Imputation\\LidarData\\epsg5071\\SelwayRiverElkCreek\\", 
##	inputRefSys="utm 11T", 
##	outputRefSys = "epsg 5071"
##)
##
###ShotgunCreek
##projectLidarBatchFile(studyArea="ShotgunCreek", 
##	inputDirectory="D:\\Patrick\\LidarData\\Idaho\\ShotgunCreek\\Points\\LAZ\\", 
##	outputDirectory="D:\\Patrick\\CMS\\N_ID_Imputation\\LidarData\\epsg5071\\ShotgunCreek\\", 
##	inputRefSys="utm 11T", 
##	outputRefSys = "epsg 5071"
##)
##
###SlateCreek
##projectLidarBatchFile(studyArea="SlateCreek", 
##	inputDirectory="D:\\Patrick\\LidarData\\Idaho\\SlateCreek\\Points\\Classified\\MCC\\", 
##	outputDirectory="D:\\Patrick\\CMS\\N_ID_Imputation\\LidarData\\epsg5071\\SlateCreek\\", 
##	inputRefSys="utm 11T", 
##	outputRefSys = "epsg 5071"
##)
##
##
###SouthForkSalmon
##projectLidarBatchFile(studyArea="SouthForkSalmon", 
##	inputDirectory="D:\\Patrick\\LidarData\\Idaho\\SouthForkSalmon\\Points\\LAZ\\", 
##	outputDirectory="D:\\Patrick\\CMS\\N_ID_Imputation\\LidarData\\epsg5071\\SouthForkSalmon\\", 
##	inputRefSys="utm 11T", 
##	outputRefSys = "epsg 5071"
##)
##
##
###Stanley
##projectLidarBatchFile(studyArea="Stanley", 
##	inputDirectory="D:\\Patrick\\LidarData\\Idaho\\Stanley\\Points\\LAZ\\", 
##	outputDirectory="D:\\Patrick\\CMS\\N_ID_Imputation\\LidarData\\epsg5071\\Stanley\\", 
##	inputRefSys="utm 11T", 
##	outputRefSys = "epsg 5071"
##)
##
##
###StJoe
##projectLidarBatchFile(studyArea="StJoe", 
##	inputDirectory="D:\\Patrick\\LidarData\\Idaho\\StJoe\\Points\\Classified\\MCC\\", 
##	outputDirectory="D:\\Patrick\\CMS\\N_ID_Imputation\\LidarData\\epsg5071\\StJoe\\", 
##	inputRefSys="utm 11T", 
##	outputRefSys = "epsg 5071"
##)
##
##
###TwinCreek
##projectLidarBatchFile(studyArea="TwinCreek", 
##	inputDirectory="D:\\Patrick\\LidarData\\Idaho\\TwinCreek\\Points\\LAZ\\", 
##	outputDirectory="D:\\Patrick\\CMS\\N_ID_Imputation\\LidarData\\epsg5071\\TwinCreek\\", 
##	inputRefSys="utm 11T", 
##	outputRefSys = "epsg 5071"
##)
##
##
###UpperElk
##projectLidarBatchFile(studyArea="UpperElk", 
##	inputDirectory="D:\\Patrick\\LidarData\\Idaho\\UpperElk\\Points\\LAZ\\", 
##	outputDirectory="D:\\Patrick\\CMS\\N_ID_Imputation\\LidarData\\epsg5071\\UpperElk\\", 
##	inputRefSys="utm 11T", 
##	outputRefSys = "epsg 5071"
##)
##
##
###UpperLoloCreek
##projectLidarBatchFile(studyArea="UpperLoloCreek", 
##	inputDirectory="D:\\Patrick\\LidarData\\Idaho\\UpperLoloCreek\\Points\\Classified\\MCC\\", 
##	outputDirectory="D:\\Patrick\\CMS\\N_ID_Imputation\\LidarData\\epsg5071\\UpperLoloCreek\\", 
##	inputRefSys="utm 11T", 
##	outputRefSys = "epsg 5071"
##)
##
##
###ValleyCountyID
##projectLidarBatchFile(studyArea="ValleyCountyID", 
##	inputDirectory="D:\\Patrick\\LidarData\\Idaho\\ValleyCountyID\\16085C_Valley_County_Idaho_Terrain\\Source\\Classified_Point_Cloud_Data\\", 
##	outputDirectory="D:\\Patrick\\CMS\\N_ID_Imputation\\LidarData\\epsg5071\\ValleyCountyID\\", 
##	inputRefSys="utm 11T", 
##	outputRefSys = "epsg 5071"
##)
##
##
###WaldePeteKing
##projectLidarBatchFile(studyArea="WaldePeteKing", 
##	inputDirectory="D:\\Patrick\\LidarData\\Idaho\\WaldePeteKing\\Points\\LAZ\\", 
##	outputDirectory="D:\\Patrick\\CMS\\N_ID_Imputation\\LidarData\\epsg5071\\WaldePeteKing\\", 
##	inputRefSys="utm 11T", 
##	outputRefSys = "epsg 5071"
##)
##
##
###---------------------
#### Added on 2016.02.05
###BigSandCreek
##projectLidarBatchFile(studyArea="BigSandCreek", 
##	inputDirectory="D:\\Patrick\\LidarData\\Idaho\\BigSandCreek\\Points\\LAZ\\", 
##	outputDirectory="D:\\Patrick\\CMS\\N_ID_Imputation\\LidarData\\epsg5071\\BigSandCreek\\", 
##	inputRefSys="utm 11T", 
##	outputRefSys = "epsg 5071"
##)
##
##
###CoolMush
##projectLidarBatchFile(studyArea="CoolMush", 
##	inputDirectory="D:\\Patrick\\LidarData\\Idaho\\CoolMush\\Points\\LAZ\\", 
##	outputDirectory="D:\\Patrick\\CMS\\N_ID_Imputation\\LidarData\\epsg5071\\CoolMush\\", 
##	inputRefSys="utm 11T", 
##	outputRefSys = "epsg 5071"
##)
##
###CougarLeggett
##projectLidarBatchFile(studyArea="CougarLeggett", 
##	inputDirectory="D:\\Patrick\\LidarData\\Idaho\\CougarLeggett\\Points\\LAZ\\", 
##	outputDirectory="D:\\Patrick\\CMS\\N_ID_Imputation\\LidarData\\epsg5071\\CougarLeggett\\", 
##	inputRefSys="utm 11T", 
##	outputRefSys = "epsg 5071"
##)
##
###CoveRestoration
##projectLidarBatchFile(studyArea="CoveRestoration", 
##	inputDirectory="D:\\Patrick\\LidarData\\Idaho\\CoveRestoration\\Points\\LAZ\\", 
##	outputDirectory="D:\\Patrick\\CMS\\N_ID_Imputation\\LidarData\\epsg5071\\CoveRestoration\\", 
##	inputRefSys="utm 11T", 
##	outputRefSys = "epsg 5071"
##)
##
##
###Grangeville
##projectLidarBatchFile(studyArea="Grangeville", 
##	inputDirectory="D:\\Patrick\\LidarData\\Idaho\\Grangeville\\Points\\LAZ\\", 
##	outputDirectory="D:\\Patrick\\CMS\\N_ID_Imputation\\LidarData\\epsg5071\\Grangeville\\", 
##	inputRefSys="utm 11T", 
##	outputRefSys = "epsg 5071"
##)
##
##
###HeadwatersPalouse
##projectLidarBatchFile(studyArea="HeadwatersPalouse", 
##	inputDirectory="D:\\Patrick\\LidarData\\Idaho\\HeadwatersPalouse\\Points\\LAZ\\", 
##	outputDirectory="D:\\Patrick\\CMS\\N_ID_Imputation\\LidarData\\epsg5071\\HeadwatersPalouse\\", 
##	inputRefSys="utm 11T", 
##	outputRefSys = "epsg 5071"
##)
##
##
###HUC10Addition
##projectLidarBatchFile(studyArea="HUC10Addition", 
##	inputDirectory="D:\\Patrick\\LidarData\\Idaho\\HUC10Addition\\Points\\LAZ\\", 
##	outputDirectory="D:\\Patrick\\CMS\\N_ID_Imputation\\LidarData\\epsg5071\\HUC10Addition\\", 
##	inputRefSys="utm 11T", 
##	outputRefSys = "epsg 5071"
##)
##
##
###LowerLochsa
##projectLidarBatchFile(studyArea="LowerLochsa", 
##	inputDirectory="D:\\Patrick\\LidarData\\Idaho\\LowerLochsa\\Points\\LAZ\\", 
##	outputDirectory="D:\\Patrick\\CMS\\N_ID_Imputation\\LidarData\\epsg5071\\LowerLochsa\\", 
##	inputRefSys="utm 11T", 
##	outputRefSys = "epsg 5071"
##)
##
##
###MeadowCreek
##projectLidarBatchFile(studyArea="MeadowCreek", 
##	inputDirectory="D:\\Patrick\\LidarData\\Idaho\\MeadowCreek\\Points\\LAZ\\", 
##	outputDirectory="D:\\Patrick\\CMS\\N_ID_Imputation\\LidarData\\epsg5071\\MeadowCreek\\", 
##	inputRefSys="utm 11T", 
##	outputRefSys = "epsg 5071"
##)
##
##
###MeadowCreekAddition
##projectLidarBatchFile(studyArea="MeadowCreekAddition", 
##	inputDirectory="D:\\Patrick\\LidarData\\Idaho\\MeadowCreekAddition\\Points\\LAZ\\", 
##	outputDirectory="D:\\Patrick\\CMS\\N_ID_Imputation\\LidarData\\epsg5071\\MeadowCreekAddition\\", 
##	inputRefSys="utm 11T", 
##	outputRefSys = "epsg 5071"
##)
##
##
###PalouseAddition1
##projectLidarBatchFile(studyArea="PalouseAddition1", 
##	inputDirectory="D:\\Patrick\\LidarData\\Idaho\\PalouseAddition1\\Points\\LAZ\\", 
##	outputDirectory="D:\\Patrick\\CMS\\N_ID_Imputation\\LidarData\\epsg5071\\PalouseAddition1\\", 
##	inputRefSys="utm 11T", 
##	outputRefSys = "epsg 5071"
##)
##
##
###PalouseAddition2
##projectLidarBatchFile(studyArea="PalouseAddition2", 
##	inputDirectory="D:\\Patrick\\LidarData\\Idaho\\PalouseAddition2\\Points\\LAZ\\", 
##	outputDirectory="D:\\Patrick\\CMS\\N_ID_Imputation\\LidarData\\epsg5071\\PalouseAddition2\\", 
##	inputRefSys="utm 11T", 
##	outputRefSys = "epsg 5071"
##)
##
##
###PalouseAddition3
##projectLidarBatchFile(studyArea="PalouseAddition3", 
##	inputDirectory="D:\\Patrick\\LidarData\\Idaho\\PalouseAddition3\\Points\\LAZ\\", 
##	outputDirectory="D:\\Patrick\\CMS\\N_ID_Imputation\\LidarData\\epsg5071\\PalouseAddition3\\", 
##	inputRefSys="utm 11T", 
##	outputRefSys = "epsg 5071"
##)
##
##
###RigginsWestIsland
##projectLidarBatchFile(studyArea="RigginsWestIsland", 
##	inputDirectory="D:\\Patrick\\LidarData\\Idaho\\RigginsWestIsland\\Points\\LAZ\\", 
##	outputDirectory="D:\\Patrick\\CMS\\N_ID_Imputation\\LidarData\\epsg5071\\RigginsWestIsland\\", 
##	inputRefSys="utm 11T", 
##	outputRefSys = "epsg 5071"
##)
##
##
###TenTwentyMile
##projectLidarBatchFile(studyArea="TenTwentyMile", 
##	inputDirectory="D:\\Patrick\\LidarData\\Idaho\\TenTwentyMile\\Points\\LAZ\\", 
##	outputDirectory="D:\\Patrick\\CMS\\N_ID_Imputation\\LidarData\\epsg5071\\TenTwentyMile\\", 
##	inputRefSys="utm 11T", 
##	outputRefSys = "epsg 5071"
##)
##
##
###TepeePotterCreek
##projectLidarBatchFile(studyArea="TepeePotterCreek", 
##	inputDirectory="D:\\Patrick\\LidarData\\Idaho\\TepeePotterCreek\\Points\\LAZ\\", 
##	outputDirectory="D:\\Patrick\\CMS\\N_ID_Imputation\\LidarData\\epsg5071\\TepeePotterCreek\\", 
##	inputRefSys="utm 11T", 
##	outputRefSys = "epsg 5071"
##)
##
##
##
##
###2016.08.11
###From Idaho Lidar Consortium
##
###AmericanFalls
##projectLidarBatchFile(studyArea="AmericanFalls", 
##	inputDirectory="D:\\Patrick\\LidarData\\Idaho\\AmericanFalls\\Points\\LAZ\\", 
##	outputDirectory="D:\\Patrick\\CMS\\LidarData\\epsg5071\\AmericanFalls\\", 
##	inputRefSys="epsg 26912", 
##	outputRefSys = "epsg 5071"
##)
##
###BigWoodOLC2015North
##projectLidarBatchFile(studyArea="BigWoodOLC2015North", 
##	inputDirectory="D:\\Patrick\\LidarData\\Idaho\\BigWoodOLC2015North\\Points\\LAZ\\", 
##	outputDirectory="D:\\Patrick\\CMS\\LidarData\\epsg5071\\BigWoodOLC2015North\\", 
##	inputRefSys="epsg 26911", 
##	outputRefSys = "epsg 5071"
##)
##
###BigWoodOLC2015South
##projectLidarBatchFile(studyArea="BigWoodOLC2015South", 
##	inputDirectory="D:\\Patrick\\LidarData\\Idaho\\BigWoodOLC2015South\\Points\\LAZ\\", 
##	outputDirectory="D:\\Patrick\\CMS\\LidarData\\epsg5071\\BigWoodOLC2015South\\", 
##	inputRefSys="epsg 26911", 
##	outputRefSys = "epsg 5071"
##)
##
###BirdsOfPrey2011
##projectLidarBatchFile(studyArea="BirdsOfPrey2011", 
##	inputDirectory="D:\\Patrick\\LidarData\\Idaho\\BirdsOfPrey2011\\Points\\LAZ\\", 
##	outputDirectory="D:\\Patrick\\CMS\\LidarData\\epsg5071\\BirdsOfPrey2011\\", 
##	inputRefSys="epsg 26911", 
##	outputRefSys = "epsg 5071"
##)
##
##
###BoxCanyon
##projectLidarBatchFile(studyArea="BoxCanyon", 
##	inputDirectory="D:\\Patrick\\LidarData\\Idaho\\BoxCanyon\\Points\\LAZ\\", 
##	outputDirectory="D:\\Patrick\\CMS\\LidarData\\epsg5071\\BoxCanyon\\", 
##	inputRefSys="epsg 26911", 
##	outputRefSys = "epsg 5071"
##)
##
##
###BullTroutLake
##projectLidarBatchFile(studyArea="BullTroutLake", 
##	inputDirectory="D:\\Patrick\\LidarData\\Idaho\\BullTroutLake\\Points\\LAZ\\", 
##	outputDirectory="D:\\Patrick\\CMS\\LidarData\\epsg5071\\BullTroutLake\\", 
##	inputRefSys="epsg 26911", 
##	outputRefSys = "epsg 5071"
##)
##
##
###CamasNWR
###The lidar are in ESRI:102668 I dont know if this is equivalent to epsg 2887
##projectLidarBatchFile(studyArea="CamasNWR", 
##	inputDirectory="D:\\Patrick\\LidarData\\Idaho\\CamasNWR\\Points\\LAZ\\", 
##	outputDirectory="D:\\Patrick\\CMS\\LidarData\\epsg5071\\CamasNWR\\", 
##	inputRefSys="epsg 2241 -survey_feet -elevation_surveyfeet", 
##	outputRefSys = "epsg 5071"
##)
##
###CamasNWR - First got to UTM, then go to EPSG
#projectLidarToUtmBatchFile(studyArea="CamasNWR", 
#	inputDirectory="D:\\Patrick\\LidarData\\Idaho\\CamasNWR\\Points\\LAZ\\", 
#	outputDirectory="D:\\Patrick\\CMS\\LidarData\\epsg5071\\CamasNWR\\UTM\\", 
#	inputRefSys="epsg 2241 -survey_feet -elevation_surveyfeet",
#	outputRefSys = "utm 12T"
#)
###CamasNWR - Now go to EPSG 5071
#projectLidarBatchFile(studyArea="CamasNWR", 
#	inputDirectory="D:\\Patrick\\CMS\\LidarData\\epsg5071\\CamasNWR\\UTM\\", 
#	outputDirectory="D:\\Patrick\\CMS\\LidarData\\epsg5071\\CamasNWR\\", 
#	inputRefSys=NULL,
#	outputRefSys = "epsg 5071"
#)



##
###CityOfKuna2015
##projectLidarBatchFile(studyArea="CityOfKuna2015", 
##	inputDirectory="D:\\Patrick\\LidarData\\Idaho\\CityOfKuna2015\\Points\\LAZ\\", 
##	outputDirectory="D:\\Patrick\\CMS\\LidarData\\epsg5071\\CityOfKuna2015\\", 
##	inputRefSys="epsg 26911", 
##	outputRefSys = "epsg 5071"
##)
##
##
###CoeurDAleneRiver
##projectLidarBatchFile(studyArea="CoeurDAleneRiver", 
##	inputDirectory="D:\\Patrick\\LidarData\\Idaho\\CoeurDAleneRiver\\Points\\LAZ\\", 
##	outputDirectory="D:\\Patrick\\CMS\\LidarData\\epsg5071\\CoeurDAleneRiver\\", 
##	inputRefSys="epsg 26911", 
##	outputRefSys = "epsg 5071"
##)
##
##
###DryCreek2007
##projectLidarBatchFile(studyArea="DryCreek2007", 
##	inputDirectory="D:\\Patrick\\LidarData\\Idaho\\DryCreek2007\\Points\\LAZ\\", 
##	outputDirectory="D:\\Patrick\\CMS\\LidarData\\epsg5071\\DryCreek2007\\", 
##	inputRefSys="epsg 26911", 
##	outputRefSys = "epsg 5071"
##)
##
##
###DryCreek2009
##projectLidarBatchFile(studyArea="DryCreek2009", 
##	inputDirectory="D:\\Patrick\\LidarData\\Idaho\\DryCreek2009\\Points\\LAZ\\", 
##	outputDirectory="D:\\Patrick\\CMS\\LidarData\\epsg5071\\DryCreek2009\\", 
##	inputRefSys="epsg 26911", 
##	outputRefSys = "epsg 5071"
##)
##
##
###HenrysFork
##projectLidarBatchFile(studyArea="HenrysFork", 
##	inputDirectory="D:\\Patrick\\LidarData\\Idaho\\HenrysFork\\Points\\LAZ\\", 
##	outputDirectory="D:\\Patrick\\CMS\\LidarData\\epsg5071\\HenrysFork\\", 
##	inputRefSys="epsg 26912", 
##	outputRefSys = "epsg 5071"
##)
##
###Hollister2010
##projectLidarBatchFile(studyArea="Hollister2010", 
##	inputDirectory="D:\\Patrick\\LidarData\\Idaho\\Hollister2010\\Points\\LAZ\\", 
##	outputDirectory="D:\\Patrick\\CMS\\LidarData\\epsg5071\\Hollister2010\\", 
##	inputRefSys="epsg 26911", 
##	outputRefSys = "epsg 5071"
##)
##
##
###ISUPocatello - First got to UTM, then go to EPSG
#projectLidarToUtmBatchFile(studyArea="ISUPocatello", 
#	inputDirectory="D:\\Patrick\\LidarData\\Idaho\\ISUPocatello\\Points\\LAZ\\", 
#	outputDirectory="D:\\Patrick\\CMS\\LidarData\\epsg5071\\ISUPocatello\\UTM\\", 
#	inputRefSys="epsg 2241 -survey_feet -elevation_surveyfeet",
#	outputRefSys = "utm 12T"
#)
###ISUPocatello  - Now go to EPSG 5071
#projectLidarBatchFile(studyArea="ISUPocatello", 
#	inputDirectory="D:\\Patrick\\CMS\\LidarData\\epsg5071\\ISUPocatello\\UTM\\", 
#	outputDirectory="D:\\Patrick\\CMS\\LidarData\\epsg5071\\ISUPocatello\\", 
#	inputRefSys=NULL,
#	outputRefSys = "epsg 5071"
#)



##
##
###JuniperTransect
##projectLidarBatchFile(studyArea="JuniperTransect", 
##	inputDirectory="D:\\Patrick\\LidarData\\Idaho\\JuniperTransect\\Points\\LAZ\\", 
##	outputDirectory="D:\\Patrick\\CMS\\LidarData\\epsg5071\\JuniperTransect\\", 
##	inputRefSys="epsg 26911", 
##	outputRefSys = "epsg 5071"
##)
##
##
###LemhiRiver2008
##projectLidarBatchFile(studyArea="LemhiRiver2008", 
##	inputDirectory="D:\\Patrick\\LidarData\\Idaho\\LemhiRiver2008\\Points\\LAZ\\", 
##	outputDirectory="D:\\Patrick\\CMS\\LidarData\\epsg5071\\LemhiRiver2008\\", 
##	inputRefSys="epsg 26912", 
##	outputRefSys = "epsg 5071"
##)
##
##
###LemhiRiver2010
##projectLidarBatchFile(studyArea="LemhiRiver2010", 
##	inputDirectory="D:\\Patrick\\LidarData\\Idaho\\LemhiRiver2010\\Points\\LAZ\\", 
##	outputDirectory="D:\\Patrick\\CMS\\LidarData\\epsg5071\\LemhiRiver2010\\", 
##	inputRefSys="epsg 26912", 
##	outputRefSys = "epsg 5071"
##)
##
##
###LemhiRiver2011
##projectLidarBatchFile(studyArea="LemhiRiver2011", 
##	inputDirectory="D:\\Patrick\\LidarData\\Idaho\\LemhiRiver2011\\Points\\LAZ\\", 
##	outputDirectory="D:\\Patrick\\CMS\\LidarData\\epsg5071\\LemhiRiver2011\\", 
##	inputRefSys="epsg 2242 -survey_feet -elevation_surveyfeet",
##	outputRefSys = "epsg 5071"
##)
###LemhiRiver2011 - First got to UTM, then go to EPSG
#projectLidarToUtmBatchFile(studyArea="LemhiRiver2011", 
#	inputDirectory="D:\\Patrick\\LidarData\\Idaho\\LemhiRiver2011\\Points\\LAZ\\", 
#	outputDirectory="D:\\Patrick\\CMS\\LidarData\\epsg5071\\LemhiRiver2011\\UTM\\", 
#	inputRefSys="epsg 2242 -survey_feet -elevation_surveyfeet",
#	outputRefSys = "utm 12T"
#)
###LemhiRiver2011 - Now go to EPSG 5071
#projectLidarBatchFile(studyArea="LemhiRiver2011", 
#	inputDirectory="D:\\Patrick\\CMS\\LidarData\\epsg5071\\LemhiRiver2011\\UTM\\", 
#	outputDirectory="D:\\Patrick\\CMS\\LidarData\\epsg5071\\LemhiRiver2011\\", 
#	inputRefSys=NULL,
#	outputRefSys = "epsg 5071"
#)


##
##
###LemhiRiverAmonson2008
##projectLidarBatchFile(studyArea="LemhiRiverAmonson2008", 
##	inputDirectory="D:\\Patrick\\LidarData\\Idaho\\LemhiRiverAmonson2008\\Points\\LAZ\\", 
##	outputDirectory="D:\\Patrick\\CMS\\LidarData\\epsg5071\\LemhiRiverAmonson2008\\", 
##	inputRefSys="epsg 26912", 
##	outputRefSys = "epsg 5071"
##)
##
##
###LemhiSubbasin2008
##projectLidarBatchFile(studyArea="LemhiSubbasin2008", 
##	inputDirectory="D:\\Patrick\\LidarData\\Idaho\\LemhiSubbasin2008\\Points\\LAZ\\", 
##	outputDirectory="D:\\Patrick\\CMS\\LidarData\\epsg5071\\LemhiSubbasin2008\\", 
##	inputRefSys="epsg 26912", 
##	outputRefSys = "epsg 5071"
##)
##
##
###Middleton2011
##projectLidarBatchFile(studyArea="Middleton2011", 
##	inputDirectory="D:\\Patrick\\LidarData\\Idaho\\Middleton2011\\Points\\LAZ\\", 
##	outputDirectory="D:\\Patrick\\CMS\\LidarData\\epsg5071\\Middleton2011\\", 
##	inputRefSys="epsg 26911", 
##	outputRefSys = "epsg 5071"
##)
##
##
###Pahsimeroi
##projectLidarBatchFile(studyArea="Pahsimeroi", 
##	inputDirectory="D:\\Patrick\\LidarData\\Idaho\\Pahsimeroi\\Points\\LAZ\\", 
##	outputDirectory="D:\\Patrick\\CMS\\LidarData\\epsg5071\\Pahsimeroi\\", 
##	inputRefSys="epsg 26912", 
##	outputRefSys = "epsg 5071"
##)
##
##
###Pocatello2005
##projectLidarBatchFile(studyArea="Pocatello2005", 
##	inputDirectory="D:\\Patrick\\LidarData\\Idaho\\Pocatello2005\\Points\\LAZ\\", 
##	outputDirectory="D:\\Patrick\\CMS\\LidarData\\epsg5071\\Pocatello2005\\", 
##	inputRefSys="epsg 26912", 
##	outputRefSys = "epsg 5071"
##)
##
##
###Pocatello2010
##projectLidarBatchFile(studyArea="Pocatello2010", 
##	inputDirectory="D:\\Patrick\\LidarData\\Idaho\\Pocatello2010\\Points\\LAZ\\", 
##	outputDirectory="D:\\Patrick\\CMS\\LidarData\\epsg5071\\Pocatello2010\\", 
##	inputRefSys="epsg 26912", 
##	outputRefSys = "epsg 5071"
##)
##
##
###Priest2012
##projectLidarBatchFile(studyArea="Priest2012", 
##	inputDirectory="D:\\Patrick\\LidarData\\Idaho\\Priest2012\\Points\\LAZ\\", 
##	outputDirectory="D:\\Patrick\\CMS\\LidarData\\epsg5071\\Priest2012\\", 
##	inputRefSys="epsg 26911", 
##	outputRefSys = "epsg 5071"
##)
##
##
###SalmonFalls2002
##projectLidarBatchFile(studyArea="SalmonFalls2002", 
##	inputDirectory="D:\\Patrick\\LidarData\\Idaho\\SalmonFalls2002\\Points\\LAZ\\", 
##	outputDirectory="D:\\Patrick\\CMS\\LidarData\\epsg5071\\SalmonFalls2002\\", 
##	inputRefSys="epsg 26911", 
##	outputRefSys = "epsg 5071"
##)
##
##
###SalmonFalls2005
##projectLidarBatchFile(studyArea="SalmonFalls2005", 
##	inputDirectory="D:\\Patrick\\LidarData\\Idaho\\SalmonFalls2005\\Points\\LAZ\\", 
##	outputDirectory="D:\\Patrick\\CMS\\LidarData\\epsg5071\\SalmonFalls2005\\", 
##	inputRefSys="epsg 26911", 
##	outputRefSys = "epsg 5071"
##)
##
##
###SalmonFalls2010
##projectLidarBatchFile(studyArea="SalmonFalls2010", 
##	inputDirectory="D:\\Patrick\\LidarData\\Idaho\\SalmonFalls2010\\Points\\LAZ\\", 
##	outputDirectory="D:\\Patrick\\CMS\\LidarData\\epsg5071\\SalmonFalls2010\\", 
##	inputRefSys="epsg 26911", 
##	outputRefSys = "epsg 5071"
##)
##
##
###SawtoothNorth
##projectLidarBatchFile(studyArea="SawtoothNorth", 
##	inputDirectory="D:\\Patrick\\LidarData\\Idaho\\SawtoothNorth\\Points\\LAZ\\", 
##	outputDirectory="D:\\Patrick\\CMS\\LidarData\\epsg5071\\SawtoothNorth\\", 
##	inputRefSys="epsg 26911", 
##	outputRefSys = "epsg 5071"
##)
##
##
###SawtoothSouth
##projectLidarBatchFile(studyArea="SawtoothSouth", 
##	inputDirectory="D:\\Patrick\\LidarData\\Idaho\\SawtoothSouth\\Points\\LAZ\\", 
##	outputDirectory="D:\\Patrick\\CMS\\LidarData\\epsg5071\\SawtoothSouth\\", 
##	inputRefSys="epsg 26911", 
##	outputRefSys = "epsg 5071"
##)
##
##
###SheepStation2002
##projectLidarBatchFile(studyArea="SheepStation2002", 
##	inputDirectory="D:\\Patrick\\LidarData\\Idaho\\SheepStation2002\\Points\\LAZ\\", 
##	outputDirectory="D:\\Patrick\\CMS\\LidarData\\epsg5071\\SheepStation2002\\", 
##	inputRefSys="epsg 26912", 
##	outputRefSys = "epsg 5071"
##)
##
##
###SheepStationPostFire2005
##projectLidarBatchFile(studyArea="SheepStationPostFire2005", 
##	inputDirectory="D:\\Patrick\\LidarData\\Idaho\\SheepStationPostFire2005\\Points\\LAZ\\", 
##	outputDirectory="D:\\Patrick\\CMS\\LidarData\\epsg5071\\SheepStationPostFire2005\\", 
##	inputRefSys="epsg 26912", 
##	outputRefSys = "epsg 5071"
##)
##
##
###SnakeRiver2011
##projectLidarBatchFile(studyArea="SnakeRiver2011", 
##	inputDirectory="D:\\Patrick\\LidarData\\Idaho\\SnakeRiver2011\\Points\\LAZ\\", 
##	outputDirectory="D:\\Patrick\\CMS\\LidarData\\epsg5071\\SnakeRiver2011\\", 
##	inputRefSys="epsg 26912", 
##	outputRefSys = "epsg 5071"
##)
##
##
###SnakeRiver2011HeiseRoad
##projectLidarBatchFile(studyArea="SnakeRiver2011HeiseRoad", 
##	inputDirectory="D:\\Patrick\\LidarData\\Idaho\\SnakeRiver2011HeiseRoad\\Points\\LAZ\\", 
##	outputDirectory="D:\\Patrick\\CMS\\LidarData\\epsg5071\\SnakeRiver2011HeiseRoad\\", 
##	inputRefSys="epsg 26912", 
##	outputRefSys = "epsg 5071"
##)
##
##
###SnakeRiverOLC2015
##projectLidarBatchFile(studyArea="SnakeRiverOLC2015", 
##	inputDirectory="D:\\Patrick\\LidarData\\Idaho\\SnakeRiverOLC2015\\Points\\LAZ\\", 
##	outputDirectory="D:\\Patrick\\CMS\\LidarData\\epsg5071\\SnakeRiverOLC2015\\", 
##	inputRefSys="epsg 26912", 
##	outputRefSys = "epsg 5071"
##)
##
##
###SwanValley2002
##projectLidarBatchFile(studyArea="SwanValley2002", 
##	inputDirectory="D:\\Patrick\\LidarData\\Idaho\\SwanValley2002\\Points\\LAZ\\", 
##	outputDirectory="D:\\Patrick\\CMS\\LidarData\\epsg5071\\SwanValley2002\\", 
##	inputRefSys="epsg 26712", 
##	outputRefSys = "epsg 5071"
##)
##
##
###Teton
##projectLidarBatchFile(studyArea="Teton", 
##	inputDirectory="D:\\Patrick\\LidarData\\Idaho\\Teton\\Points\\LAZ\\", 
##	outputDirectory="D:\\Patrick\\CMS\\LidarData\\epsg5071\\Teton\\", 
##	inputRefSys="epsg 26712", 
##	outputRefSys = "epsg 5071"
##)
##
##
###ThunderMountain
##projectLidarBatchFile(studyArea="ThunderMountain", 
##	inputDirectory="D:\\Patrick\\LidarData\\Idaho\\ThunderMountain\\Points\\LAZ\\", 
##	outputDirectory="D:\\Patrick\\CMS\\LidarData\\epsg5071\\ThunderMountain\\", 
##	inputRefSys="epsg 26711", 
##	outputRefSys = "epsg 5071"
##)
##
##
###UpperWarren
##projectLidarBatchFile(studyArea="UpperWarren", 
##	inputDirectory="D:\\Patrick\\LidarData\\Idaho\\UpperWarren\\Points\\LAZ\\", 
##	outputDirectory="D:\\Patrick\\CMS\\LidarData\\epsg5071\\UpperWarren\\", 
##	inputRefSys="epsg 26711", 
##	outputRefSys = "epsg 5071"
##)
##
##
###WeiserRiver
##projectLidarBatchFile(studyArea="WeiserRiver", 
##	inputDirectory="D:\\Patrick\\LidarData\\Idaho\\WeiserRiver\\Points\\LAZ\\", 
##	outputDirectory="D:\\Patrick\\CMS\\LidarData\\epsg5071\\WeiserRiver\\", 
##	inputRefSys="epsg 26711", 
##	outputRefSys = "epsg 5071"
##)
##
##
##
###2016.09.15
###BoiseRiver2015
##projectLidarBatchFile(studyArea="BoiseRiver2015", 
##	inputDirectory="D:\\Patrick\\LidarData\\Idaho\\BoiseRiver2015\\Points\\LAZ\\", 
##	outputDirectory="D:\\Patrick\\CMS\\LidarData\\epsg5071\\BoiseRiver2015\\", 
##	inputRefSys="epsg 26711", 
##	outputRefSys = "epsg 5071"
##)
##
##
###BorahScarp2005
##projectLidarBatchFile(studyArea="BorahScarp2005", 
##	inputDirectory="D:\\Patrick\\LidarData\\Idaho\\BorahScarp2005\\Points\\LAZ\\", 
##	outputDirectory="D:\\Patrick\\CMS\\LidarData\\epsg5071\\BorahScarp2005\\", 
##	inputRefSys="epsg 26712", 
##	outputRefSys = "epsg 5071"
##)
##
##
###ColumbiaRiverTreaty_D5_UTM11_ID
##projectLidarBatchFile(studyArea="ColumbiaRiverTreaty_D5_UTM11_ID", 
##	inputDirectory="D:\\Patrick\\LidarData\\Idaho\\ColumbiaRiverTreaty_D5_UTM11_ID\\Points\\LAZ\\", 
##	outputDirectory="D:\\Patrick\\CMS\\LidarData\\epsg5071\\ColumbiaRiverTreaty_D5_UTM11_ID\\", 
##	inputRefSys="epsg 26711", 
##	outputRefSys = "epsg 5071"
##)
##
##
###ReynoldsCreek2009
##projectLidarBatchFile(studyArea="ReynoldsCreek2009", 
##	inputDirectory="D:\\Patrick\\LidarData\\Idaho\\ReynoldsCreek2009\\Points\\LAZ\\", 
##	outputDirectory="D:\\Patrick\\CMS\\LidarData\\epsg5071\\ReynoldsCreek2009\\", 
##	inputRefSys="epsg 26711", 
##	outputRefSys = "epsg 5071"
##)
##
###SmithCreek
##projectLidarBatchFile(studyArea="SmithCreek", 
##	inputDirectory="D:\\Patrick\\LidarData\\Idaho\\SmithCreek\\Points\\LAZ\\", 
##	outputDirectory="D:\\Patrick\\CMS\\LidarData\\epsg5071\\SmithCreek\\", 
##	inputRefSys="epsg 26711", 
##	outputRefSys = "epsg 5071"
##)
##
##
##
##
##
###2016.09.19
###SouthMountain2007
##projectLidarBatchFile(studyArea="SouthMountain2007", 
##	inputDirectory="D:\\Patrick\\LidarData\\Idaho\\SouthMountain2007\\Points\\LAZ\\", 
##	outputDirectory="D:\\Patrick\\CMS\\LidarData\\epsg5071\\SouthMountain2007\\", 
##	inputRefSys="epsg 26711", 
##	outputRefSys = "epsg 5071"
##)
##
##
##
###2016.09.27
###ReynoldsCreek2007
##projectLidarBatchFile(studyArea="ReynoldsCreek2007", 
##	inputDirectory="D:\\Patrick\\LidarData\\Idaho\\ReynoldsCreek2007\\Points\\LAZ\\", 
##	outputDirectory="D:\\Patrick\\CMS\\LidarData\\epsg5071\\ReynoldsCreek2007\\", 
##	inputRefSys="epsg 26711", 
##	outputRefSys = "epsg 5071"
##)



#2017.01.18
#WADNR_BIA2008
#Projection: Washington State Plane North (FIPS 4601); Vertical datum: NAVD88/Geoid03; Horizontal
#	datum: NAD83/91 (HARN); Units: US survey feet
#projectLidarBatchFile(studyArea="WADNR_Springdale2008", 
#	inputDirectory="F:\\Patrick\\LidarData\\Washington\\WADNR_BIA2008\\Points\\LAZ\\", 
#	outputDirectory="D:\\Patrick\\CMS\\LidarData\\epsg5071\\WADNR_BIA2008\\", 
#	inputRefSys="sp83 WA_N -feet -elevation_feet", 
#	outputRefSys = "epsg 5071"
#)

#WADNR_PierreLake2008
#Projection: Washington State Plane North (FIPS 4601); Vertical datum: NAVD88/Geoid03; Horizontal
#	datum: NAD83/91 (HARN); Units: US survey feet
#projectLidarBatchFile(studyArea="WADNR_PierreLake2008", 
#	inputDirectory="F:\\Patrick\\LidarData\\Washington\\WADNR_PierreLake2008\\Points\\LAZ\\", 
#	outputDirectory="D:\\Patrick\\CMS\\LidarData\\epsg5071\\WADNR_SpringPierreLake2008dale2008\\", 
#	inputRefSys="sp83 WA_N -feet -elevation_feet", 
#	outputRefSys = "epsg 5071"
#)

#WADNR_Springdale2008
#Projection: Washington State Plane North (FIPS 4601); Vertical datum: NAVD88/Geoid03; Horizontal
#	datum: NAD83/91 (HARN); Units: US survey feet
#projectLidarBatchFile(studyArea="WADNR_Springdale2008", 
#	inputDirectory="F:\\Patrick\\LidarData\\Washington\\WADNR_Springdale2008\\Points\\LAZ\\", 
#	outputDirectory="D:\\Patrick\\CMS\\LidarData\\epsg5071\\WADNR_Springdale2008\\", 
#	inputRefSys="sp83 WA_N -feet -elevation_feet", 
#	outputRefSys = "epsg 5071"
#)


#ColvilleNF2008
#ESRI:102748: NAD 1983 StatePlane Washington North FIPS 4601 Feet
#projectLidarBatchFile(studyArea="ColvilleNF2008", 
#	inputDirectory="F:\\Patrick\\LidarData\\Washington\\ColvilleNF2008\\Points\\LAZ\\", 
#	outputDirectory="D:\\Patrick\\CMS\\LidarData\\epsg5071\\ColvilleNF2008\\", 
#	inputRefSys="sp83 WA_N -feet -elevation_feet", 
#	outputRefSys = "epsg 5071"
#)
#
#
##ColvilleNF2012
##ESPG:6340: NAD83(2011) / UTM zone 11N
#projectLidarBatchFile(studyArea="ColvilleNF2012", 
#	inputDirectory="F:\\Patrick\\LidarData\\Washington\\ColvilleNF2012\\Points\\LAZ\\", 
#	outputDirectory="D:\\Patrick\\CMS\\LidarData\\epsg5071\\ColvilleNF2012\\", 
#	inputRefSys="epsg 6340",
#	outputRefSys = "epsg 5071"
#)
#
#
##ColvilleNF2014
##Projection: Washington State Plane North (FIPS 4601); Vertical datum: NAVD88/Geoid03; Horizontal
##	datum: NAD83/91 (HARN); Units: US survey feet
#projectLidarBatchFile(studyArea="ColvilleNF2014", 
#	inputDirectory="F:\\Patrick\\LidarData\\Washington\\ColvilleNF2014\\Points\\LAZ\\", 
#	outputDirectory="D:\\Patrick\\CMS\\LidarData\\epsg5071\\ColvilleNF2014\\", 
#	inputRefSys=NULL, #ref system already defined (USFS Region 6 Albers)
#	outputRefSys = "epsg 5071"
#)
#

##ColvilleNFEast2015
##Projection: Washington State Plane North (FIPS 4601); Vertical datum: NAVD88/Geoid03; Horizontal
##	datum: NAD83/91 (HARN); Units: US survey feet
#projectLidarBatchFile(studyArea="ColvilleNFEast2015", 
#	inputDirectory="F:\\Patrick\\LidarData\\Washington\\ColvilleNFEast2015\\Points\\LAZ\\", 
#	outputDirectory="D:\\Patrick\\CMS\\LidarData\\epsg5071\\ColvilleNFEast2015\\", 
#	inputRefSys=NULL, #ref system already defined (USFS Region 6 Albers)
#	outputRefSys = "epsg 5071"
#)

##ColvilleNFWest2015
##Projection: Washington State Plane North (FIPS 4601); Vertical datum: NAVD88/Geoid03; Horizontal
##	datum: NAD83/91 (HARN); Units: US survey feet
#projectLidarBatchFile(studyArea="ColvilleNFWest2015", 
#	inputDirectory="F:\\Patrick\\LidarData\\Washington\\ColvilleNFWest2015\\Points\\LAZ\\", 
#	outputDirectory="D:\\Patrick\\CMS\\LidarData\\epsg5071\\ColvilleNFWest2015\\", 
#	inputRefSys=NULL, #ref system already defined (USFS Region 6 Albers)
#	outputRefSys = "epsg 5071"
#)

#
#
#
##Blackfoot
#projectLidarBatchFile(studyArea="Blackfoot", 
#	inputDirectory="F:\\Patrick\\LidarData\\Montana\\Blackfoot\\Points\\LAZ\\", 
#	outputDirectory="D:\\Patrick\\CMS\\LidarData\\epsg5071\\Blackfoot\\", 
#	inputRefSys=NULL, #ref system already defined (epsg 26912)
#	outputRefSys = "epsg 5071"
#)
#
#
#
##BuckHolland
#projectLidarBatchFile(studyArea="BuckHolland", 
#	inputDirectory="F:\\Patrick\\LidarData\\Montana\\BuckHolland\\Points\\LAZ\\", 
#	outputDirectory="D:\\Patrick\\CMS\\LidarData\\epsg5071\\BuckHolland\\", 
#	inputRefSys=NULL, #ref system already defined (epsg 26912)
#	outputRefSys = "epsg 5071"
#)
#
#
##Clearwater
#projectLidarBatchFile(studyArea="Clearwater", 
#	inputDirectory="F:\\Patrick\\LidarData\\Montana\\Clearwater\\Points\\LAZ\\", 
#	outputDirectory="D:\\Patrick\\CMS\\LidarData\\epsg5071\\Clearwater\\", 
#	inputRefSys=NULL, #ref system already defined (epsg 26912)
#	outputRefSys = "epsg 5071"
#)
#
#
##ColtBertha
#projectLidarBatchFile(studyArea="ColtBertha", 
#	inputDirectory="F:\\Patrick\\LidarData\\Montana\\ColtBertha\\Points\\LAZ\\", 
#	outputDirectory="D:\\Patrick\\CMS\\LidarData\\epsg5071\\ColtBertha\\", 
#	inputRefSys=NULL, #ref system already defined (epsg 26912)
#	outputRefSys = "epsg 5071"
#)
#
#
##Dalton
#projectLidarBatchFile(studyArea="Dalton", 
#	inputDirectory="F:\\Patrick\\LidarData\\Montana\\Dalton\\Points\\LAZ\\", 
#	outputDirectory="D:\\Patrick\\CMS\\LidarData\\epsg5071\\Dalton\\", 
#	inputRefSys=NULL, #ref system already defined (epsg 26912)
#	outputRefSys = "epsg 5071"
#)
#
#
##DaltonB
#projectLidarBatchFile(studyArea="DaltonB", 
#	inputDirectory="F:\\Patrick\\LidarData\\Montana\\DaltonB\\Points\\LAZ\\", 
#	outputDirectory="D:\\Patrick\\CMS\\LidarData\\epsg5071\\DaltonB\\", 
#	inputRefSys=NULL, #ref system already defined (epsg 26912)
#	outputRefSys = "epsg 5071"
#)
#
#
##HemlockElk
#projectLidarBatchFile(studyArea="HemlockElk", 
#	inputDirectory="F:\\Patrick\\LidarData\\Montana\\HemlockElk\\Points\\LAZ\\", 
#	outputDirectory="D:\\Patrick\\CMS\\LidarData\\epsg5071\\HemlockElk\\", 
#	inputRefSys=NULL, #ref system already defined (epsg 26912)
#	outputRefSys = "epsg 5071"
#)
#
#
##LowerCottonwood
#projectLidarBatchFile(studyArea="LowerCottonwood", 
#	inputDirectory="N:\\Patrick\\LidarData\\Montana\\LowerCottonwood\\Points\\LAZ\\", 
#	outputDirectory="G:\\FR\\MFalkows-VMStorage\\Patrick\\CMS\\LidarData\\epsg5071\\LowerCottonwood\\", 
#	inputRefSys="epsg 26912", #ref system already defined (epsg 26912)
#	outputRefSys = "epsg 5071"
#)
#
#
##LowerMonture
#projectLidarBatchFile(studyArea="LowerMonture", 
#	inputDirectory="F:\\Patrick\\LidarData\\Montana\\LowerMonture\\Points\\LAZ\\", 
#	outputDirectory="D:\\Patrick\\CMS\\LidarData\\epsg5071\\LowerMonture\\", 
#	inputRefSys=NULL, #ref system already defined (epsg 26912)
#	outputRefSys = "epsg 5071"
#)
#
#
##LowerMorell
#projectLidarBatchFile(studyArea="LowerMorell", 
#	inputDirectory="F:\\Patrick\\LidarData\\Montana\\LowerMorell\\Points\\LAZ\\", 
#	outputDirectory="D:\\Patrick\\CMS\\LidarData\\epsg5071\\LowerMorell\\", 
#	inputRefSys=NULL, #ref system already defined (epsg 26912)
#	outputRefSys = "epsg 5071"
#)
#
#
##LowerTrail
#projectLidarBatchFile(studyArea="LowerTrail", 
#	inputDirectory="F:\\Patrick\\LidarData\\Montana\\LowerTrail\\Points\\LAZ\\", 
#	outputDirectory="D:\\Patrick\\CMS\\LidarData\\epsg5071\\LowerTrail\\", 
#	inputRefSys=NULL, #ref system already defined (epsg 26912)
#	outputRefSys = "epsg 5071"
#)
#
#
##MeadowSmith
#projectLidarBatchFile(studyArea="MeadowSmith", 
#	inputDirectory="F:\\Patrick\\LidarData\\Montana\\MeadowSmith\\Points\\LAZ\\", 
#	outputDirectory="D:\\Patrick\\CMS\\LidarData\\epsg5071\\MeadowSmith\\", 
#	inputRefSys=NULL, #ref system already defined (epsg 26912)
#	outputRefSys = "epsg 5071"
#)
#
#
##MontureCreek
#projectLidarBatchFile(studyArea="MontureCreek", 
#	inputDirectory="F:\\Patrick\\LidarData\\Montana\\MontureCreek\\Points\\LAZ\\", 
#	outputDirectory="D:\\Patrick\\CMS\\LidarData\\epsg5071\\MontureCreek\\", 
#	inputRefSys=NULL, #ref system already defined (epsg 26912)
#	outputRefSys = "epsg 5071"
#)
#
#
##NorthLake
#projectLidarBatchFile(studyArea="NorthLake", 
#	inputDirectory="F:\\Patrick\\LidarData\\Montana\\NorthLake\\Points\\LAZ\\", 
#	outputDirectory="D:\\Patrick\\CMS\\LidarData\\epsg5071\\NorthLake\\", 
#	inputRefSys=NULL, #ref system already defined (epsg 26912)
#	outputRefSys = "epsg 5071"
#)
#
#
##NorthSwan
#projectLidarBatchFile(studyArea="NorthSwan", 
#	inputDirectory="F:\\Patrick\\LidarData\\Montana\\NorthSwan\\Points\\LAZ\\", 
#	outputDirectory="D:\\Patrick\\CMS\\LidarData\\epsg5071\\NorthSwan\\", 
#	inputRefSys=NULL, #ref system already defined (epsg 26912)
#	outputRefSys = "epsg 5071"
#)
#
#
##Rice
#projectLidarBatchFile(studyArea="Rice", 
#	inputDirectory="F:\\Patrick\\LidarData\\Montana\\Rice\\Points\\LAZ\\", 
#	outputDirectory="D:\\Patrick\\CMS\\LidarData\\epsg5071\\Rice\\", 
#	inputRefSys=NULL, #ref system already defined (epsg 26912)
#	outputRefSys = "epsg 5071"
#)
#
#
##Richmond
#projectLidarBatchFile(studyArea="Richmond", 
#	inputDirectory="F:\\Patrick\\LidarData\\Montana\\Richmond\\Points\\LAZ\\", 
#	outputDirectory="D:\\Patrick\\CMS\\LidarData\\epsg5071\\Richmond\\", 
#	inputRefSys=NULL, #ref system already defined (epsg 26912)
#	outputRefSys = "epsg 5071"
#)
#
#
##Stemple
#projectLidarBatchFile(studyArea="Stemple", 
#	inputDirectory="F:\\Patrick\\LidarData\\Montana\\Stemple\\Points\\LAZ\\", 
#	outputDirectory="D:\\Patrick\\CMS\\LidarData\\epsg5071\\Stemple\\", 
#	inputRefSys=NULL, #ref system already defined (epsg 26912)
#	outputRefSys = "epsg 5071"
#)
#
#
##StoneWall
#projectLidarBatchFile(studyArea="StoneWall", 
#	inputDirectory="F:\\Patrick\\LidarData\\Montana\\StoneWall\\Points\\LAZ\\", 
#	outputDirectory="D:\\Patrick\\CMS\\LidarData\\epsg5071\\StoneWall\\", 
#	inputRefSys=NULL, #ref system already defined (ESRI 102412)
#	outputRefSys = "epsg 5071"
#)
#
#
##WestFlesher
#projectLidarBatchFile(studyArea="WestFlesher", 
#	inputDirectory="F:\\Patrick\\LidarData\\Montana\\WestFlesher\\Points\\LAZ\\", 
#	outputDirectory="D:\\Patrick\\CMS\\LidarData\\epsg5071\\WestFlesher\\", 
#	inputRefSys=NULL, #ref system already defined (epsg 26912)
#	outputRefSys = "epsg 5071"
#)
#
#
##Woodward
#projectLidarBatchFile(studyArea="Woodward", 
#	inputDirectory="F:\\Patrick\\LidarData\\Montana\\Woodward\\Points\\LAZ\\", 
#	outputDirectory="D:\\Patrick\\CMS\\LidarData\\epsg5071\\Woodward\\", 
#	inputRefSys=NULL, #ref system already defined (epsg 26912)
#	outputRefSys = "epsg 5071"
#)
#
#
#


#Added 2017.02.21 
###Damon
##projectLidarBatchFile(studyArea="Damon", 
##	inputDirectory="F:\\Patrick\\LidarData\\Oregon\\Damon\\Points\\LAZ\\", 
##	outputDirectory="D:\\Patrick\\CMS\\LidarData\\epsg5071\\Damon\\", 
##	inputRefSys="epsg 26911", 
##	outputRefSys = "epsg 5071"
##)


#Added 2018.02.20
#American2016
#projectLidarBatchFile(studyArea="American2016", 
#	inputDirectory="G:\\FR\\MFalkows-VMStorage\\Patrick\\LidarData\\Idaho\\American2016\\Points\\LAZ\\", 
#	outputDirectory="G:\\FR\\MFalkows-VMStorage\\Patrick\\CMS\\LidarData\\epsg5071\\American2016\\", 
#	inputRefSys= "epsg 26711", 
#	outputRefSys = "epsg 5071"
#)

##BallTrout2016
#projectLidarBatchFile(studyArea="BallTrout2016", 
#	inputDirectory="G:\\FR\\MFalkows-VMStorage\\Patrick\\LidarData\\Idaho\\BallTrout2016\\Points\\LAZ\\", 
#	outputDirectory="G:\\FR\\MFalkows-VMStorage\\Patrick\\CMS\\LidarData\\epsg5071\\BallTrout2016\\", 
#	inputRefSys=NULL, 
#	outputRefSys = "epsg 5071"
#)

##BinarchCreek2016
#projectLidarBatchFile(studyArea="BinarchCreek2016", 
#	inputDirectory="G:\\FR\\MFalkows-VMStorage\\Patrick\\LidarData\\Idaho\\BinarchCreek2016\\Points\\LAZ\\", 
#	outputDirectory="G:\\FR\\MFalkows-VMStorage\\Patrick\\CMS\\LidarData\\epsg5071\\BinarchCreek2016\\", 
#	inputRefSys=NULL, 
#	outputRefSys = "epsg 5071"
#)

##BuckskinSaddle2016
#projectLidarBatchFile(studyArea="BuckskinSaddle2016", 
#	inputDirectory="G:\\FR\\MFalkows-VMStorage\\Patrick\\LidarData\\Idaho\\BuckskinSaddle2016\\Points\\LAZ\\", 
#	outputDirectory="G:\\FR\\MFalkows-VMStorage\\Patrick\\CMS\\LidarData\\epsg5071\\BuckskinSaddle2016\\", 
#	inputRefSys=NULL, 
#	outputRefSys = "epsg 5071"
#)

##CampDawson2016
#projectLidarBatchFile(studyArea="CampDawson2016", 
#	inputDirectory="G:\\FR\\MFalkows-VMStorage\\Patrick\\LidarData\\Idaho\\CampDawson2016\\Points\\LAZ\\", 
#	outputDirectory="G:\\FR\\MFalkows-VMStorage\\Patrick\\CMS\\LidarData\\epsg5071\\CampDawson2016\\", 
#	inputRefSys=NULL, 
#	outputRefSys = "epsg 5071"
#)

##CowGrassCreekAllotments2016
#projectLidarBatchFile(studyArea="CowGrassCreekAllotments2016", 
#	inputDirectory="G:\\FR\\MFalkows-VMStorage\\Patrick\\LidarData\\Idaho\\CowGrassCreekAllotments2016\\Points\\LAZ\\", 
#	outputDirectory="G:\\FR\\MFalkows-VMStorage\\Patrick\\CMS\\LidarData\\epsg5071\\CowGrassCreekAllotments2016\\", 
#	inputRefSys=NULL, 
#	outputRefSys = "epsg 5071"
#)

##FishhookHomestead2016
#projectLidarBatchFile(studyArea="FishhookHomestead2016", 
#	inputDirectory="G:\\FR\\MFalkows-VMStorage\\Patrick\\LidarData\\Idaho\\FishhookHomestead2016\\Points\\LAZ\\", 
#	outputDirectory="G:\\FR\\MFalkows-VMStorage\\Patrick\\CMS\\LidarData\\epsg5071\\FishhookHomestead2016\\", 
#	inputRefSys=NULL, 
#	outputRefSys = "epsg 5071"
#)

##Emerald2016
#projectLidarBatchFile(studyArea="Emerald2016", 
#	inputDirectory="G:\\FR\\MFalkows-VMStorage\\Patrick\\LidarData\\Idaho\\Emerald2016\\Points\\LAZ\\", 
#	outputDirectory="G:\\FR\\MFalkows-VMStorage\\Patrick\\CMS\\LidarData\\epsg5071\\Emerald2016\\", 
#	inputRefSys=NULL, 
#	outputRefSys = "epsg 5071"
#)

##QuartzUpperJoe2016
#projectLidarBatchFile(studyArea="QuartzUpperJoe2016", 
#	inputDirectory="G:\\FR\\MFalkows-VMStorage\\Patrick\\LidarData\\Idaho\\QuartzUpperJoe2016\\Points\\LAZ\\", 
#	outputDirectory="G:\\FR\\MFalkows-VMStorage\\Patrick\\CMS\\LidarData\\epsg5071\\QuartzUpperJoe2016\\", 
#	inputRefSys=NULL, 
#	outputRefSys = "epsg 5071"
#)

##Glover2016
#projectLidarBatchFile(studyArea="Glover2016", 
#	inputDirectory="G:\\FR\\MFalkows-VMStorage\\Patrick\\LidarData\\Idaho\\Glover2016\\Points\\LAZ\\", 
#	outputDirectory="G:\\FR\\MFalkows-VMStorage\\Patrick\\CMS\\LidarData\\epsg5071\\Glover2016\\", 
#	inputRefSys=NULL, 
#	outputRefSys = "epsg 5071"
#)

##Slate2016
#projectLidarBatchFile(studyArea="Slate2016", 
#	inputDirectory="G:\\FR\\MFalkows-VMStorage\\Patrick\\LidarData\\Idaho\\Slate2016\\Points\\LAZ\\", 
#	outputDirectory="G:\\FR\\MFalkows-VMStorage\\Patrick\\CMS\\LidarData\\epsg5071\\Slate2016\\", 
#	inputRefSys=NULL, 
#	outputRefSys = "epsg 5071"
#)

##LacyLamoosh2016
#projectLidarBatchFile(studyArea="LacyLamoosh2016", 
#	inputDirectory="G:\\FR\\MFalkows-VMStorage\\Patrick\\LidarData\\Idaho\\LacyLamoosh2016\\Points\\LAZ\\", 
#	outputDirectory="G:\\FR\\MFalkows-VMStorage\\Patrick\\CMS\\LidarData\\epsg5071\\LacyLamoosh2016\\", 
#	inputRefSys=NULL, 
#	outputRefSys = "epsg 5071"
#)

##HughesMeadow2016
#projectLidarBatchFile(studyArea="HughesMeadow2016", 
#	inputDirectory="G:\\FR\\MFalkows-VMStorage\\Patrick\\LidarData\\Idaho\\HughesMeadow2016\\Points\\LAZ\\", 
#	outputDirectory="G:\\FR\\MFalkows-VMStorage\\Patrick\\CMS\\LidarData\\epsg5071\\HughesMeadow2016\\", 
#	inputRefSys=NULL, 
#	outputRefSys = "epsg 5071"
#)

##BuncoRoushRossi2016
#projectLidarBatchFile(studyArea="BuncoRoushRossi2016", 
#	inputDirectory="G:\\FR\\MFalkows-VMStorage\\Patrick\\LidarData\\Idaho\\BuncoRoushRossi2016\\Points\\LAZ\\", 
#	outputDirectory="G:\\FR\\MFalkows-VMStorage\\Patrick\\CMS\\LidarData\\epsg5071\\BuncoRoushRossi2016\\", 
#	inputRefSys= "epsg 26711", 
#	outputRefSys = "epsg 5071"
#)


#printCRS

#xx
#projectLidarBatchFile(studyArea="xx", 
#	inputDirectory="G:\\FR\\MFalkows-VMStorage\\Patrick\\LidarData\\Idaho\\xx\\Points\\LAZ\\", 
#	outputDirectory="G:\\FR\\MFalkows-VMStorage\\Patrick\\CMS\\LidarData\\epsg5071\\xx\\", 
#	inputRefSys="epsg 26711", 
#	outputRefSys = "epsg 5071"
#)






