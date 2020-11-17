rm(list=ls())

#Name:	100_Main_ish.R
#Author:	PA Fekety
#Purpose:	This script has 4 main functions:
#		1: copies the FUSION AP file structure
#		2: runs a QAQC check on the lidar data
#		3. creates .DTMs from ground returns
#		4. creates the PRP setup file for FUSION AP
#Date:	2017.01.11




#2017.01.11	New
#2017.01.27	Rerunning AP with Van Kane's set points. 
#		Using "_Blank_20170127"
#2017.02.21	Added Damon


#--------------------------------
#--------------------------------
# load functions from outside scripts
#--------------------------------
#--------------------------------

#Script 010 BuildFusionApFileStructure
#source("D:\\Patrick\\CMS\\LidarMetrics\\epsg5071_Trans\\FusionAP\\_ProcessingScripts\\010_BuildFusionApFileStructure.R")
#Script 011 RunQAQCBatchFile
#source("D:\\Patrick\\CMS\\LidarMetrics\\epsg5071_Trans\\FusionAP\\_ProcessingScripts\\011_RunQAQCBatchFile.R")
#Script 012 CreateBufferedDtmScript
#source("D:\\Patrick\\CMS\\LidarMetrics\\epsg5071_Trans\\FusionAP\\_ProcessingScripts\\012_CreateBufferedDtmScript.R")
#Script 013 CreateAPSettingsPRP
#source("D:\\Patrick\\CMS\\LidarMetrics\\epsg5071_Trans\\FusionAP\\_ProcessingScripts\\013_CreateAPSettingsPRP.R")


#Script 010 BuildFusionApFileStructure
source("G:\\FR\\MFalkows-VMStorage\\Patrick\\CMS\\LidarMetrics\\epsg5071_Trans\\FusionAP\\_ProcessingScripts\\010_BuildFusionApFileStructure.R")
#Script 011 RunQAQCBatchFile
source("G:\\FR\\MFalkows-VMStorage\\Patrick\\CMS\\LidarMetrics\\epsg5071_Trans\\FusionAP\\_ProcessingScripts\\011_RunQAQCBatchFile.R")
#Script 012 CreateBufferedDtmScript
source("G:\\FR\\MFalkows-VMStorage\\Patrick\\CMS\\LidarMetrics\\epsg5071_Trans\\FusionAP\\_ProcessingScripts\\012_CreateBufferedDtmScript.R")
#Script 013 CreateAPSettingsPRP
source("G:\\FR\\MFalkows-VMStorage\\Patrick\\CMS\\LidarMetrics\\epsg5071_Trans\\FusionAP\\_ProcessingScripts\\013_CreateAPSettingsPRP.R")

#G:\\FR\\MFalkows-VMStorage

#--------------------------------
#--------------------------------
# Processing parameters
#--------------------------------
#--------------------------------

##- Cell size for rasters
CELLSIZE <- 30

#Number of processing cores
NCORES <- 6





#
#--------------------------------
#--------------------------------
#Directories
#--------------------------------
#--------------------------------

#Directory for FUSION AP Runs
DIR_BASE <- "G:\\FR\\MFalkows-VMStorage\\Patrick\\CMS\\LidarMetrics\\epsg5071_Trans\\FusionAP\\"

#Directory where the RPR files are stored
DIR_PRP <- paste0(DIR_BASE, "_ApSettings\\")

#Directory where the blank AP scripts are stored
DIR_BLANK <- paste0(DIR_BASE, "_Blank_20170127\\")



#--------------------------------
#--------------------------------
# Functions
#--------------------------------
#--------------------------------


#Name:
#	main
#Purpose:
#	1: copies the FUSION AP file structure
#	2: runs a QAQC check on the lidar data
#	3. creates .DTMs from ground returns
#	4. creates the PRP setup file for FUSION AP
#Inputs:
#	studyArea
#	DIR_BLANK
#	DIR_BASE
#	CELLSIZE
#	NCORES
#Outputs:
#	1. FUSION AP file structure
#	2. QAQC Report
#	list of lidar files
#	DTMs from ground returns
#	the setup files necessary that are fed to the FUSION AP GUI

main <- function(studyArea, DIR_BLANK, DIR_BASE, CELLSIZE, NCORES)
{
	#Directory where the Translated LAS files are stored
	DIR_LIDAR <- paste0("G:\\FR\\MFalkows-VMStorage\\Patrick\\CMS\\LidarData\\epsg5071\\", studyArea, "\\")
	
	copyFusionFileStructure(studyArea, InputFileStructure=DIR_BLANK, OutputFileStructure=DIR_BASE)
	#Run runQAQC, if it already hasn't been run
	if(!file.exists(paste0(DIR_BASE, studyArea, "\\Products\\QAQC\\QAQC.html"))){
		RunQaQc(studyArea=studyArea, DIR_BASE=DIR_BASE, DIR_LIDAR=DIR_LIDAR)
	}
	#Create Buffered DTMs, if they doesn't exist
	if(length(dir(paste0(DIR_BASE, studyArea, "\\Deliverables\\DTM"))) == 0){
		runBufferedDtm(studyArea=studyArea, DIR_BASE=DIR_BASE, DIR_LIDAR=DIR_LIDAR)
	}
	#Create PRP, if it doesn't exist
	if(!file.exists(paste0(DIR_BASE, "_ApSettings\\", studyArea, "_APSetup.prp"))){
		createPRP(studyArea=studyArea, cellSize=CELLSIZE, nCores=NCORES, DIR_BASE=DIR_BASE, DIR_LIDAR=DIR_LIDAR)
		#Create a copy of the PRP
		file.copy(from=paste0(DIR_BASE, "_ApSettings\\", studyArea, "_APSetup.prp" ), to=paste0(DIR_BASE, studyArea, "\\Processing"), overwrite=TRUE)
	}
}


#This code replaces the contents of PROCESSING HOME
#studyAreas <- dir(DIR_BASE)
#studyAreas <- studyAreas[-c(1:6, 8)] # some aren't study areas, others have been processed
#for(studyArea in studyAreas){
#	#Delete old directory
#	unlink(paste0(DIR_BASE, studyArea, "\\Processing\\AP"), recursive=T )
#	
#	#use ROBOCOPY to copy / paste from Blank to Project-specific directory
#	shell(
#		paste(
#			"MD", paste0(DIR_BASE, studyArea, "\\Processing\\AP"),
#			"&",
#			"ROBOCOPY", paste0(DIR_BLANK, "Processing\\AP"), paste0(DIR_BASE, studyArea, "\\Processing\\AP"), "/S /E"
#			)
#		)
#}

#This code replaces the contents of postblock.bat
#studyAreas <- dir(DIR_BASE)
#studyAreas <- studyAreas[-c(1:24)] # some aren't study areas, others have been processed
#for(studyArea in studyAreas){
#	#Delete old version of postblock.bat
#	unlink(paste0(DIR_BASE, studyArea, "\\Processing\\AP\\postblock.bat"))
#	
#	#copy / paste from Blank to Project-specific directory
#	file.copy(from=paste0(DIR_BLANK, "Processing\\AP\\postblock.bat"), to=paste0(DIR_BASE, studyArea, "\\Processing\\AP\\postblock.bat"))
#}



#--------------------------------
#--------------------------------
# All the processing steps to create the PRP file
#--------------------------------
#--------------------------------

#NOTE::



#main(studyArea="DCEF2011", DIR_BLANK=DIR_BLANK, DIR_BASE=DIR_BASE, CELLSIZE=CELLSIZE, NCORES=NCORES)
#main(studyArea="PREF2011", DIR_BLANK=DIR_BLANK, DIR_BASE=DIR_BASE, CELLSIZE=CELLSIZE, NCORES=NCORES)
#main(studyArea="ElkCity", DIR_BLANK=DIR_BLANK, DIR_BASE=DIR_BASE, CELLSIZE=CELLSIZE, NCORES=NCORES)
#main(studyArea="Bannock", DIR_BLANK=DIR_BLANK, DIR_BASE=DIR_BASE, CELLSIZE=CELLSIZE, NCORES=NCORES)

#main(studyArea="MoscowMtn2007", DIR_BLANK=DIR_BLANK, DIR_BASE=DIR_BASE, CELLSIZE=CELLSIZE, NCORES=NCORES)



#main(studyArea="AmericanFalls", DIR_BLANK=DIR_BLANK, DIR_BASE=DIR_BASE, CELLSIZE=CELLSIZE, NCORES=NCORES)
#main(studyArea="Bannock", DIR_BLANK=DIR_BLANK, DIR_BASE=DIR_BASE, CELLSIZE=CELLSIZE, NCORES=NCORES)
#main(studyArea="BigSandCreek", DIR_BLANK=DIR_BLANK, DIR_BASE=DIR_BASE, CELLSIZE=CELLSIZE, NCORES=NCORES)
#main(studyArea="BigWoodOLC2015North", DIR_BLANK=DIR_BLANK, DIR_BASE=DIR_BASE, CELLSIZE=CELLSIZE, NCORES=NCORES)
#main(studyArea="BigWoodOLC2015South", DIR_BLANK=DIR_BLANK, DIR_BASE=DIR_BASE, CELLSIZE=CELLSIZE, NCORES=NCORES)
#main(studyArea="BirdsOfPrey2011", DIR_BLANK=DIR_BLANK, DIR_BASE=DIR_BASE, CELLSIZE=CELLSIZE, NCORES=NCORES)
#main(studyArea="BoiseRiver2015", DIR_BLANK=DIR_BLANK, DIR_BASE=DIR_BASE, CELLSIZE=CELLSIZE, NCORES=NCORES)
#main(studyArea="BorahScarp2005", DIR_BLANK=DIR_BLANK, DIR_BASE=DIR_BASE, CELLSIZE=CELLSIZE, NCORES=NCORES)
#main(studyArea="BoxCanyon", DIR_BLANK=DIR_BLANK, DIR_BASE=DIR_BASE, CELLSIZE=CELLSIZE, NCORES=NCORES)
#main(studyArea="BullTroutLake", DIR_BLANK=DIR_BLANK, DIR_BASE=DIR_BASE, CELLSIZE=CELLSIZE, NCORES=NCORES)
#main(studyArea="CamasNWR", DIR_BLANK=DIR_BLANK, DIR_BASE=DIR_BASE, CELLSIZE=CELLSIZE, NCORES=NCORES)
#main(studyArea="CityOfKuna2015", DIR_BLANK=DIR_BLANK, DIR_BASE=DIR_BASE, CELLSIZE=CELLSIZE, NCORES=NCORES)
#main(studyArea="ClearCreek", DIR_BLANK=DIR_BLANK, DIR_BASE=DIR_BASE, CELLSIZE=CELLSIZE, NCORES=NCORES)
#main(studyArea="CoeurDAleneRiver", DIR_BLANK=DIR_BLANK, DIR_BASE=DIR_BASE, CELLSIZE=CELLSIZE, NCORES=NCORES)
#main(studyArea="ColumbiaRiverTreaty_D5_UTM11_ID", DIR_BLANK=DIR_BLANK, DIR_BASE=DIR_BASE, CELLSIZE=CELLSIZE, NCORES=NCORES)
#main(studyArea="CoolMush", DIR_BLANK=DIR_BLANK, DIR_BASE=DIR_BASE, CELLSIZE=CELLSIZE, NCORES=NCORES)
#main(studyArea="CorralHogMeadowCreekPotlatchRiver", DIR_BLANK=DIR_BLANK, DIR_BASE=DIR_BASE, CELLSIZE=CELLSIZE, NCORES=NCORES)
#main(studyArea="CougarLeggett", DIR_BLANK=DIR_BLANK, DIR_BASE=DIR_BASE, CELLSIZE=CELLSIZE, NCORES=NCORES)
#main(studyArea="CoveRestoration", DIR_BLANK=DIR_BLANK, DIR_BASE=DIR_BASE, CELLSIZE=CELLSIZE, NCORES=NCORES)
#main(studyArea="CrookedRiver", DIR_BLANK=DIR_BLANK, DIR_BASE=DIR_BASE, CELLSIZE=CELLSIZE, NCORES=NCORES)
#main(studyArea="DCEF2011", DIR_BLANK=DIR_BLANK, DIR_BASE=DIR_BASE, CELLSIZE=CELLSIZE, NCORES=NCORES)
#main(studyArea="DryCreek2007", DIR_BLANK=DIR_BLANK, DIR_BASE=DIR_BASE, CELLSIZE=CELLSIZE, NCORES=NCORES)
#main(studyArea="DryCreek2009", DIR_BLANK=DIR_BLANK, DIR_BASE=DIR_BASE, CELLSIZE=CELLSIZE, NCORES=NCORES)
#main(studyArea="DutchOven", DIR_BLANK=DIR_BLANK, DIR_BASE=DIR_BASE, CELLSIZE=CELLSIZE, NCORES=NCORES)
#main(studyArea="ElkCity", DIR_BLANK=DIR_BLANK, DIR_BASE=DIR_BASE, CELLSIZE=CELLSIZE, NCORES=NCORES)
#main(studyArea="EmeraldCreek", DIR_BLANK=DIR_BLANK, DIR_BASE=DIR_BASE, CELLSIZE=CELLSIZE, NCORES=NCORES)
#main(studyArea="Fernan", DIR_BLANK=DIR_BLANK, DIR_BASE=DIR_BASE, CELLSIZE=CELLSIZE, NCORES=NCORES)
#main(studyArea="FrenchCreekPreacherNorthForkFront", DIR_BLANK=DIR_BLANK, DIR_BASE=DIR_BASE, CELLSIZE=CELLSIZE, NCORES=NCORES)
#main(studyArea="Grangeville", DIR_BLANK=DIR_BLANK, DIR_BASE=DIR_BASE, CELLSIZE=CELLSIZE, NCORES=NCORES)
#main(studyArea="HeadwatersPalouse", DIR_BLANK=DIR_BLANK, DIR_BASE=DIR_BASE, CELLSIZE=CELLSIZE, NCORES=NCORES)
#main(studyArea="HenrysFork", DIR_BLANK=DIR_BLANK, DIR_BASE=DIR_BASE, CELLSIZE=CELLSIZE, NCORES=NCORES)
#main(studyArea="Hollister2010", DIR_BLANK=DIR_BLANK, DIR_BASE=DIR_BASE, CELLSIZE=CELLSIZE, NCORES=NCORES)
#main(studyArea="HUC10Addition", DIR_BLANK=DIR_BLANK, DIR_BASE=DIR_BASE, CELLSIZE=CELLSIZE, NCORES=NCORES)
#main(studyArea="ISUPocatello", DIR_BLANK=DIR_BLANK, DIR_BASE=DIR_BASE, CELLSIZE=CELLSIZE, NCORES=NCORES)
#main(studyArea="JackWaite", DIR_BLANK=DIR_BLANK, DIR_BASE=DIR_BASE, CELLSIZE=CELLSIZE, NCORES=NCORES)
#main(studyArea="JuniperTransect", DIR_BLANK=DIR_BLANK, DIR_BASE=DIR_BASE, CELLSIZE=CELLSIZE, NCORES=NCORES)
#main(studyArea="Kamiah", DIR_BLANK=DIR_BLANK, DIR_BASE=DIR_BASE, CELLSIZE=CELLSIZE, NCORES=NCORES)
#main(studyArea="LaundryChinaOsier", DIR_BLANK=DIR_BLANK, DIR_BASE=DIR_BASE, CELLSIZE=CELLSIZE, NCORES=NCORES)
#main(studyArea="LemhiRiver2008", DIR_BLANK=DIR_BLANK, DIR_BASE=DIR_BASE, CELLSIZE=CELLSIZE, NCORES=NCORES)
#main(studyArea="LemhiRiver2010", DIR_BLANK=DIR_BLANK, DIR_BASE=DIR_BASE, CELLSIZE=CELLSIZE, NCORES=NCORES)
#main(studyArea="LemhiRiver2011", DIR_BLANK=DIR_BLANK, DIR_BASE=DIR_BASE, CELLSIZE=CELLSIZE, NCORES=NCORES)
#main(studyArea="LemhiRiverAmonson2008", DIR_BLANK=DIR_BLANK, DIR_BASE=DIR_BASE, CELLSIZE=CELLSIZE, NCORES=NCORES)
#main(studyArea="LemhiSubbasin2008", DIR_BLANK=DIR_BLANK, DIR_BASE=DIR_BASE, CELLSIZE=CELLSIZE, NCORES=NCORES)
#main(studyArea="LoloCreekElDoradoCreek", DIR_BLANK=DIR_BLANK, DIR_BASE=DIR_BASE, CELLSIZE=CELLSIZE, NCORES=NCORES)
#main(studyArea="LowerLochsa", DIR_BLANK=DIR_BLANK, DIR_BASE=DIR_BASE, CELLSIZE=CELLSIZE, NCORES=NCORES)
#main(studyArea="MeadowCreek", DIR_BLANK=DIR_BLANK, DIR_BASE=DIR_BASE, CELLSIZE=CELLSIZE, NCORES=NCORES)
#main(studyArea="MeadowCreekAddition", DIR_BLANK=DIR_BLANK, DIR_BASE=DIR_BASE, CELLSIZE=CELLSIZE, NCORES=NCORES)
#main(studyArea="Middleton2011", DIR_BLANK=DIR_BLANK, DIR_BASE=DIR_BASE, CELLSIZE=CELLSIZE, NCORES=NCORES)
#main(studyArea="MillCreekHungryRidge", DIR_BLANK=DIR_BLANK, DIR_BASE=DIR_BASE, CELLSIZE=CELLSIZE, NCORES=NCORES)
#main(studyArea="MoscowMtn2003", DIR_BLANK=DIR_BLANK, DIR_BASE=DIR_BASE, CELLSIZE=CELLSIZE, NCORES=NCORES)
#main(studyArea="MoscowMtn2007", DIR_BLANK=DIR_BLANK, DIR_BASE=DIR_BASE, CELLSIZE=CELLSIZE, NCORES=NCORES)
#main(studyArea="MoscowMtn2009", DIR_BLANK=DIR_BLANK, DIR_BASE=DIR_BASE, CELLSIZE=CELLSIZE, NCORES=NCORES)
#main(studyArea="Musselshell", DIR_BLANK=DIR_BLANK, DIR_BASE=DIR_BASE, CELLSIZE=CELLSIZE, NCORES=NCORES)
#main(studyArea="NezPerce", DIR_BLANK=DIR_BLANK, DIR_BASE=DIR_BASE, CELLSIZE=CELLSIZE, NCORES=NCORES)
#main(studyArea="Pahsimeroi", DIR_BLANK=DIR_BLANK, DIR_BASE=DIR_BASE, CELLSIZE=CELLSIZE, NCORES=NCORES)
#main(studyArea="PalouseAddition1", DIR_BLANK=DIR_BLANK, DIR_BASE=DIR_BASE, CELLSIZE=CELLSIZE, NCORES=NCORES)
#main(studyArea="PalouseAddition2", DIR_BLANK=DIR_BLANK, DIR_BASE=DIR_BASE, CELLSIZE=CELLSIZE, NCORES=NCORES)
#main(studyArea="PalouseAddition3", DIR_BLANK=DIR_BLANK, DIR_BASE=DIR_BASE, CELLSIZE=CELLSIZE, NCORES=NCORES)
#main(studyArea="PayetteA2", DIR_BLANK=DIR_BLANK, DIR_BASE=DIR_BASE, CELLSIZE=CELLSIZE, NCORES=NCORES)
#main(studyArea="PayetteA3", DIR_BLANK=DIR_BLANK, DIR_BASE=DIR_BASE, CELLSIZE=CELLSIZE, NCORES=NCORES)
#main(studyArea="PayetteA4", DIR_BLANK=DIR_BLANK, DIR_BASE=DIR_BASE, CELLSIZE=CELLSIZE, NCORES=NCORES)
#main(studyArea="PayetteA6", DIR_BLANK=DIR_BLANK, DIR_BASE=DIR_BASE, CELLSIZE=CELLSIZE, NCORES=NCORES)
#main(studyArea="Pocatello2005", DIR_BLANK=DIR_BLANK, DIR_BASE=DIR_BASE, CELLSIZE=CELLSIZE, NCORES=NCORES)
#main(studyArea="Pocatello2010", DIR_BLANK=DIR_BLANK, DIR_BASE=DIR_BASE, CELLSIZE=CELLSIZE, NCORES=NCORES)
#main(studyArea="Potlatch", DIR_BLANK=DIR_BLANK, DIR_BASE=DIR_BASE, CELLSIZE=CELLSIZE, NCORES=NCORES)
#main(studyArea="Powell", DIR_BLANK=DIR_BLANK, DIR_BASE=DIR_BASE, CELLSIZE=CELLSIZE, NCORES=NCORES)
#main(studyArea="PREF2002", DIR_BLANK=DIR_BLANK, DIR_BASE=DIR_BASE, CELLSIZE=CELLSIZE, NCORES=NCORES)
#main(studyArea="PREF2011", DIR_BLANK=DIR_BLANK, DIR_BASE=DIR_BASE, CELLSIZE=CELLSIZE, NCORES=NCORES)
#main(studyArea="Priest2012", DIR_BLANK=DIR_BLANK, DIR_BASE=DIR_BASE, CELLSIZE=CELLSIZE, NCORES=NCORES)
#main(studyArea="ReynoldsCreek2007", DIR_BLANK=DIR_BLANK, DIR_BASE=DIR_BASE, CELLSIZE=CELLSIZE, NCORES=NCORES)
#main(studyArea="ReynoldsCreek2009", DIR_BLANK=DIR_BLANK, DIR_BASE=DIR_BASE, CELLSIZE=CELLSIZE, NCORES=NCORES)
#main(studyArea="RigginsWestIsland", DIR_BLANK=DIR_BLANK, DIR_BASE=DIR_BASE, CELLSIZE=CELLSIZE, NCORES=NCORES)
#main(studyArea="SalmonFalls2002", DIR_BLANK=DIR_BLANK, DIR_BASE=DIR_BASE, CELLSIZE=CELLSIZE, NCORES=NCORES)
#main(studyArea="SalmonFalls2005", DIR_BLANK=DIR_BLANK, DIR_BASE=DIR_BASE, CELLSIZE=CELLSIZE, NCORES=NCORES)
#main(studyArea="SalmonFalls2010", DIR_BLANK=DIR_BLANK, DIR_BASE=DIR_BASE, CELLSIZE=CELLSIZE, NCORES=NCORES)
#main(studyArea="SawtoothNorth", DIR_BLANK=DIR_BLANK, DIR_BASE=DIR_BASE, CELLSIZE=CELLSIZE, NCORES=NCORES)
#main(studyArea="SawtoothSouth", DIR_BLANK=DIR_BLANK, DIR_BASE=DIR_BASE, CELLSIZE=CELLSIZE, NCORES=NCORES)
#main(studyArea="SelwayRiverElkCreek", DIR_BLANK=DIR_BLANK, DIR_BASE=DIR_BASE, CELLSIZE=CELLSIZE, NCORES=NCORES)
#main(studyArea="SheepStation2002", DIR_BLANK=DIR_BLANK, DIR_BASE=DIR_BASE, CELLSIZE=CELLSIZE, NCORES=NCORES)
#main(studyArea="SheepStationPostFire2005", DIR_BLANK=DIR_BLANK, DIR_BASE=DIR_BASE, CELLSIZE=CELLSIZE, NCORES=NCORES)
#main(studyArea="ShotgunCreek", DIR_BLANK=DIR_BLANK, DIR_BASE=DIR_BASE, CELLSIZE=CELLSIZE, NCORES=NCORES)
#main(studyArea="SlateCreek", DIR_BLANK=DIR_BLANK, DIR_BASE=DIR_BASE, CELLSIZE=CELLSIZE, NCORES=NCORES)
#main(studyArea="SmithCreek", DIR_BLANK=DIR_BLANK, DIR_BASE=DIR_BASE, CELLSIZE=CELLSIZE, NCORES=NCORES)
#main(studyArea="SnakeRiver2011", DIR_BLANK=DIR_BLANK, DIR_BASE=DIR_BASE, CELLSIZE=CELLSIZE, NCORES=NCORES)
#main(studyArea="SnakeRiver2011HeiseRoad", DIR_BLANK=DIR_BLANK, DIR_BASE=DIR_BASE, CELLSIZE=CELLSIZE, NCORES=NCORES)
#main(studyArea="SnakeRiverOLC2015", DIR_BLANK=DIR_BLANK, DIR_BASE=DIR_BASE, CELLSIZE=CELLSIZE, NCORES=NCORES)
#main(studyArea="SouthForkSalmon", DIR_BLANK=DIR_BLANK, DIR_BASE=DIR_BASE, CELLSIZE=CELLSIZE, NCORES=NCORES)
#main(studyArea="SouthMountain2007", DIR_BLANK=DIR_BLANK, DIR_BASE=DIR_BASE, CELLSIZE=CELLSIZE, NCORES=NCORES)
#main(studyArea="Stanley", DIR_BLANK=DIR_BLANK, DIR_BASE=DIR_BASE, CELLSIZE=CELLSIZE, NCORES=NCORES)
#main(studyArea="StJoe", DIR_BLANK=DIR_BLANK, DIR_BASE=DIR_BASE, CELLSIZE=CELLSIZE, NCORES=NCORES)
#main(studyArea="SwanValley2002", DIR_BLANK=DIR_BLANK, DIR_BASE=DIR_BASE, CELLSIZE=CELLSIZE, NCORES=NCORES)
#main(studyArea="TenTwentyMile", DIR_BLANK=DIR_BLANK, DIR_BASE=DIR_BASE, CELLSIZE=CELLSIZE, NCORES=NCORES)
#main(studyArea="TepeePotterCreek", DIR_BLANK=DIR_BLANK, DIR_BASE=DIR_BASE, CELLSIZE=CELLSIZE, NCORES=NCORES)
#main(studyArea="Teton", DIR_BLANK=DIR_BLANK, DIR_BASE=DIR_BASE, CELLSIZE=CELLSIZE, NCORES=NCORES)
#main(studyArea="ThunderMountain", DIR_BLANK=DIR_BLANK, DIR_BASE=DIR_BASE, CELLSIZE=CELLSIZE, NCORES=NCORES)
#main(studyArea="TwinCreek", DIR_BLANK=DIR_BLANK, DIR_BASE=DIR_BASE, CELLSIZE=CELLSIZE, NCORES=NCORES)
#main(studyArea="UpperElk", DIR_BLANK=DIR_BLANK, DIR_BASE=DIR_BASE, CELLSIZE=CELLSIZE, NCORES=NCORES)
#main(studyArea="UpperLoloCreek", DIR_BLANK=DIR_BLANK, DIR_BASE=DIR_BASE, CELLSIZE=CELLSIZE, NCORES=NCORES)
#main(studyArea="UpperWarren", DIR_BLANK=DIR_BLANK, DIR_BASE=DIR_BASE, CELLSIZE=CELLSIZE, NCORES=NCORES)
#main(studyArea="ValleyCountyID", DIR_BLANK=DIR_BLANK, DIR_BASE=DIR_BASE, CELLSIZE=CELLSIZE, NCORES=NCORES)
#main(studyArea="WaldePeteKing", DIR_BLANK=DIR_BLANK, DIR_BASE=DIR_BASE, CELLSIZE=CELLSIZE, NCORES=NCORES)
#main(studyArea="WeiserRiver", DIR_BLANK=DIR_BLANK, DIR_BASE=DIR_BASE, CELLSIZE=CELLSIZE, NCORES=NCORES)

#2017.01.19 Washington and Montana units added
#main(studyArea="ColvilleNF2012", DIR_BLANK=DIR_BLANK, DIR_BASE=DIR_BASE, CELLSIZE=CELLSIZE, NCORES=NCORES)
#main(studyArea="ColvilleNF2014", DIR_BLANK=DIR_BLANK, DIR_BASE=DIR_BASE, CELLSIZE=CELLSIZE, NCORES=NCORES)

#main(studyArea="Blackfoot", DIR_BLANK=DIR_BLANK, DIR_BASE=DIR_BASE, CELLSIZE=CELLSIZE, NCORES=NCORES)
#main(studyArea="BuckHolland", DIR_BLANK=DIR_BLANK, DIR_BASE=DIR_BASE, CELLSIZE=CELLSIZE, NCORES=NCORES)
#main(studyArea="Clearwater", DIR_BLANK=DIR_BLANK, DIR_BASE=DIR_BASE, CELLSIZE=CELLSIZE, NCORES=NCORES)
#main(studyArea="ColtBertha", DIR_BLANK=DIR_BLANK, DIR_BASE=DIR_BASE, CELLSIZE=CELLSIZE, NCORES=NCORES)
#main(studyArea="Dalton", DIR_BLANK=DIR_BLANK, DIR_BASE=DIR_BASE, CELLSIZE=CELLSIZE, NCORES=NCORES)
#main(studyArea="DaltonB", DIR_BLANK=DIR_BLANK, DIR_BASE=DIR_BASE, CELLSIZE=CELLSIZE, NCORES=NCORES)
#main(studyArea="HemlockElk", DIR_BLANK=DIR_BLANK, DIR_BASE=DIR_BASE, CELLSIZE=CELLSIZE, NCORES=NCORES)
#main(studyArea="LowerCottonwood", DIR_BLANK=DIR_BLANK, DIR_BASE=DIR_BASE, CELLSIZE=CELLSIZE, NCORES=NCORES)
#main(studyArea="LowerMonture", DIR_BLANK=DIR_BLANK, DIR_BASE=DIR_BASE, CELLSIZE=CELLSIZE, NCORES=NCORES)
#main(studyArea="LowerMorell", DIR_BLANK=DIR_BLANK, DIR_BASE=DIR_BASE, CELLSIZE=CELLSIZE, NCORES=NCORES)
#main(studyArea="LowerTrail", DIR_BLANK=DIR_BLANK, DIR_BASE=DIR_BASE, CELLSIZE=CELLSIZE, NCORES=NCORES)
#main(studyArea="MeadowSmith", DIR_BLANK=DIR_BLANK, DIR_BASE=DIR_BASE, CELLSIZE=CELLSIZE, NCORES=NCORES)
#main(studyArea="MontureCreek", DIR_BLANK=DIR_BLANK, DIR_BASE=DIR_BASE, CELLSIZE=CELLSIZE, NCORES=NCORES)
#main(studyArea="NorthLake", DIR_BLANK=DIR_BLANK, DIR_BASE=DIR_BASE, CELLSIZE=CELLSIZE, NCORES=NCORES)
#main(studyArea="NorthSwan", DIR_BLANK=DIR_BLANK, DIR_BASE=DIR_BASE, CELLSIZE=CELLSIZE, NCORES=NCORES)
#main(studyArea="Rice", DIR_BLANK=DIR_BLANK, DIR_BASE=DIR_BASE, CELLSIZE=CELLSIZE, NCORES=NCORES)
#main(studyArea="Richmond", DIR_BLANK=DIR_BLANK, DIR_BASE=DIR_BASE, CELLSIZE=CELLSIZE, NCORES=NCORES)
#main(studyArea="Stemple", DIR_BLANK=DIR_BLANK, DIR_BASE=DIR_BASE, CELLSIZE=CELLSIZE, NCORES=NCORES)
#main(studyArea="Stonewall", DIR_BLANK=DIR_BLANK, DIR_BASE=DIR_BASE, CELLSIZE=CELLSIZE, NCORES=NCORES)
#main(studyArea="WestFlesher", DIR_BLANK=DIR_BLANK, DIR_BASE=DIR_BASE, CELLSIZE=CELLSIZE, NCORES=NCORES)
#main(studyArea="Woodward", DIR_BLANK=DIR_BLANK, DIR_BASE=DIR_BASE, CELLSIZE=CELLSIZE, NCORES=NCORES)

#main(studyArea="Damon", DIR_BLANK=DIR_BLANK, DIR_BASE=DIR_BASE, CELLSIZE=CELLSIZE, NCORES=NCORES)

#2017.09.08
#main(studyArea="ColvilleNFWest2015", DIR_BLANK=DIR_BLANK, DIR_BASE=DIR_BASE, CELLSIZE=CELLSIZE, NCORES=NCORES)
#main(studyArea="ColvilleNFEast2015", DIR_BLANK=DIR_BLANK, DIR_BASE=DIR_BASE, CELLSIZE=CELLSIZE, NCORES=NCORES)


#2018.02.20
#
#Dies
#Nominal coverage image created: G:\FR\MFalkows-VMStorage\Patrick\CMS\LidarMetrics\epsg5071_Trans\FusionAP\American2016\Products\QAQC\QAQC_overall_coverage.jpg
#Nominal coverage area image file produced:
#
#main(studyArea="American2016", DIR_BLANK=DIR_BLANK, DIR_BASE=DIR_BASE, CELLSIZE=CELLSIZE, NCORES=NCORES)

#main(studyArea="BinarchCreek2016", DIR_BLANK=DIR_BLANK, DIR_BASE=DIR_BASE, CELLSIZE=CELLSIZE, NCORES=NCORES)
#main(studyArea="CampDawson2016", DIR_BLANK=DIR_BLANK, DIR_BASE=DIR_BASE, CELLSIZE=CELLSIZE, NCORES=NCORES)
#main(studyArea="BuckskinSaddle2016", DIR_BLANK=DIR_BLANK, DIR_BASE=DIR_BASE, CELLSIZE=CELLSIZE, NCORES=NCORES)
#main(studyArea="Slate2016", DIR_BLANK=DIR_BLANK, DIR_BASE=DIR_BASE, CELLSIZE=CELLSIZE, NCORES=NCORES)
#main(studyArea="Glover2016", DIR_BLANK=DIR_BLANK, DIR_BASE=DIR_BASE, CELLSIZE=CELLSIZE, NCORES=NCORES)
#main(studyArea="LacyLamoosh2016", DIR_BLANK=DIR_BLANK, DIR_BASE=DIR_BASE, CELLSIZE=CELLSIZE, NCORES=NCORES)
#main(studyArea="Emerald2016", DIR_BLANK=DIR_BLANK, DIR_BASE=DIR_BASE, CELLSIZE=CELLSIZE, NCORES=NCORES)
#main(studyArea="CowGrassCreekAllotments2016", DIR_BLANK=DIR_BLANK, DIR_BASE=DIR_BASE, CELLSIZE=CELLSIZE, NCORES=NCORES)

#Dies around 496 
#Scanning file 496 of 515: G:\FR\MFalkows-VMStorage\Patrick\CMS\LidarData\epsg5071\BuncoRoushRossi2016\FPC_IDPROS_540000_5272500_20160812_Trans3000000.laz...Done
#main(studyArea="BuncoRoushRossi2016", DIR_BLANK=DIR_BLANK, DIR_BASE=DIR_BASE, CELLSIZE=CELLSIZE, NCORES=NCORES)

#main(studyArea="BallTrout2016", DIR_BLANK=DIR_BLANK, DIR_BASE=DIR_BASE, CELLSIZE=CELLSIZE, NCORES=NCORES)
#main(studyArea="QuartzUpperJoe2016", DIR_BLANK=DIR_BLANK, DIR_BASE=DIR_BASE, CELLSIZE=CELLSIZE, NCORES=NCORES)
#main(studyArea="FishhookHomestead2016", DIR_BLANK=DIR_BLANK, DIR_BASE=DIR_BASE, CELLSIZE=CELLSIZE, NCORES=NCORES)

