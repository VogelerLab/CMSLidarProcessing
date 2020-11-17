#rm(list=ls())
#aa=Sys.time()

#Name:	010_BuildFusionApFileStructure.R
#Author:	PA Fekety
#Purpose:	Creates the file structure used by the FUSION - Area Processor
#Date:	2016.08.16



#2016.08.16	New
#2016.08.17	Reran for project for Idaho lidar consortium
#		Changed the blank directory from "A_Blank" to "A_Blank_20160816", 
#		which includes code to create rumple, canopy height models, etc
#2016.08.18	Renamed script as 03_BuildFusionFileStructure.R (formerly 02_BuildFusionFileStructure.R)
#		Added '/index' switch to the catalog command in runQAQC.bat
#2016.09.07	Reran to have consistent naming system after updating FUSION file structure.
#		Renamed 'D:\Patrick\CMS\LidarMetrics\epsg5071\' as 'D:\Patrick\CMS\LidarMetrics\epsg5071_Trans\'
#2016.09.15	Added BoiseRiver2015, BorahScarp2005, ColumbiaRiverTreaty_D5_UTM11_ID, ReynoldsCreek2009, SmithCreek
#2016.09.19	Added SouthMountain2007
#2016.09.29	Added ReynoldsCreek2007
#2017.01.10	New, based on D:\Patrick\CMS\LidarData\Scripts\02_BuildFusionFileStructure.R 
#		which was for the LTK processor


#The below note is no longer applicable!!
#NOTE: this script needs to first create the file structure for FUSION before trying to make the DTMs
#To do so, copy "A_Blank" file structure
#I should first download the newer version of LTK workflow


#--------------------------------
#--------------------------------
#Load Packages, Define Variables
#--------------------------------
#--------------------------------

#Directory for FUSION AP Runs
#DIR_BASE <- "D:\\Patrick\\CMS\\LidarMetrics\\epsg5071_Trans\\FusionAP\\"

#Directory for the blank database
#DIR_Blank <- paste0(DIR_BASE, "_A_Blank_20170105")

#--------------------------------
#--------------------------------
#Define Functions
#--------------------------------
#--------------------------------


#Purpose:
#	Copies the FUSION structure from "A_blank" and renames it according to the study area name
#Inputs:
#	studyArea - (char) name of the study area
#	InputFileStructure - (char) file path to the base FUSION file structure
#	OutputFileStructure  - (char) file path where the new file structure will be saved
#Outputs:
#	FUSION file structure

copyFusionFileStructure <- function(studyArea=NULL, InputFileStructure=NULL, OutputFileStructure=NULL){

	#check to see file structure already exists
	if(!dir.exists(paste0(OutputFileStructure, studyArea))) {
#		shell(
#			paste(
#				"MD", paste0(OutputFileStructure, studyArea)
#				)
#			)
		shell(
			paste(
				"ROBOCOPY", InputFileStructure, paste0(OutputFileStructure, studyArea), "/S /E"
				)
			)
	}
	flush.console()
}


#ROBOCOPY G:\FR\MFalkows-VMStorage\Patrick\CMS\LidarMetrics\epsg5071_Trans\FusionAP\_Blank_20170127\ G:\FR\MFalkows-VMStorage\Patrick\CMS\LidarMetrics\epsg5071_Trans\FusionAP\American2016 /S /E



#--------------------------------
#--------------------------------
#Create FUSION file structure
#--------------------------------
#--------------------------------


#copyFusionFileStructure(studyArea="DCEF2011", InputFileStructure=DIR_Blank, OutputFileStructure=DIR_BASE)




