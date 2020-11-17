rm(list=ls())

#Name:	110_Run_APFusionBat.R
#Author:	PA Fekety
#Purpose:	This script runs the batch file APFusion.bat which has been created by the AP GUI
#Date:	2017.01.15

#2017.2.21	Added Damon
#2017.01.30	Running with Van and Bob's set points 
#2017.01.20	Added logic to check if the APFusion.bat file exists.
#		Set up a big run for the weekend
#2017.01.15	New



#--------------------------------
#--------------------------------
#Directories
#--------------------------------
#--------------------------------

#Directory for FUSION AP Runs
DIR_BASE <- "G:\\FR\\MFalkows-VMStorage\\Patrick\\CMS\\LidarMetrics\\epsg5071_Trans\\FusionAP\\"


#--------------------------------
#--------------------------------
# Functions
#--------------------------------
#--------------------------------

#Vector of potential study areas. Note: not all directories represent a study area
potentialStudyAreas <- dir(DIR_BASE)

#Drop these
DROP <- c(
	"_APScripts",
	"_ApSettings",
	"_Blank_20170105",
	"_ProcessingScripts",
	"APnotes.pptx"
)

potentialStudyAreas <- setdiff(potentialStudyAreas, DROP)

#Make sure all study areas have APFusion.bat

noAP <- vector()
for(potentialStudyArea in potentialStudyAreas){
	if(!file.exists(paste0(DIR_BASE, potentialStudyArea , "\\Processing\\AP\\APFusion.bat"))) {
		noAP <- c(noAP, potentialStudyArea)
	}
}
noAP

#Remove Study areas that don't have APFusion.bat
studyAreas <- setdiff(potentialStudyAreas, noAP)

#Drop these other study areas
studyAreas <- setdiff(studyAreas, "AmericanFalls")


#2017.01.30 Start running AP
studyAreas <- c(
"CamasNWR",
"CougarLeggett",
"CoveRestoration",
"CrookedRiver",
"Bannock",
"CoeurDAleneRiver",
"ColtBertha",
#"CoolMush",
"CorralHogMeadowCreekPotlatchRiver", 
"ClearCreek",
"Clearwater", 
"CamasNWR", 
"Blackfoot",
 
"BorahScarp2005",
"BoxCanyon",
"BuckHolland",
"BullTroutLake",
"CityOfKuna2015",

"BoiseRiver2015",
"BigWoodOLC2015North",
"BigWoodOLC2015South",
"BirdsOfPrey2011",
"ColumbiaRiverTreaty_D5_UTM11_ID",
"Dalton",
"DaltonB",
"DCEF2011",
"DryCreek2007",
"DryCreek2009",
"DutchOven",
"ElkCity",
"EmeraldCreek",
"Fernan", 
"FrenchCreekPreacherNorthForkFront",
"Grangeville",
"HeadwatersPalouse",
"HemlockElk",
"HenrysFork",
"Hollister2010",
 
"ISUPocatello",
"LoloCreekElDoradoCreek", 
"MillCreekHungryRidge",
"MoscowMtn2003",
"MoscowMtn2007",
"MoscowMtn2009",
"Musselshell", 
"PayetteA2", 
"PayetteA3", 
"PayetteA4", 
"PayetteA6", 
"Powell", 
"PREF2002",
"PREF2011",
"SelwayRiverElkCreek",
"SlateCreek",
"Stanley",
"StJoe",
"TepeePotterCreek",
"TwinCreek",
"UpperElk",
"UpperLoloCreek",
"WaldePeteKing",
"ShotgunCreek",

"HUC10Addition",
"JackWaite",
"JuniperTransect",
"LaundryChinaOsier",
"LemhiRiver2008", 
"LemhiRiver2010",
"LemhiRiver2011",
"LemhiRiverAmonson2008",
"LemhiSubbasin2008", 
"LowerLochsa", 
"LowerMonture",
"LowerMorell", 
"LowerTrail",
"MeadowCreek", 
"MeadowCreekAddition", 
"MeadowSmith",
"Middleton2011",
"MontureCreek", 
#"NezPerce", #blocks are too large
"NorthLake",
"NorthSwan",

"Damon",
"SouthForkSalmon",
"WestFlesher",
"WeiserRiver",
"ValleyCountyID",
"UpperWarren",
"ThunderMountain",
"Teton",
"SwanValley2002",
"SouthMountain2007",
"SnakeRiver2011HeiseRoad",
"SnakeRiver2011",
"SmithCreek",
"SheepStationPostFire2005",
"SheepStation2002",
"SawtoothSouth",
"SawtoothNorth",
"SalmonFalls2010",
"SalmonFalls2005",
"SalmonFalls2002",
#"RigginsWestIsland",
"Richmond",
"Rice",

"ReynoldsCreek2007",
#"Potlatch",
"Pocatello2010",
"Pocatello2005",
"PalouseAddition3",
"ReynoldsCreek2009"
#"PalouseAddition2",
#"PalouseAddition1",
#"Pahsimeroi"

)


#FYI postblock.bat is the last script


#Check to see if the main batch file exists.
for(i in 1:length(studyAreas)){
	if(!file.exists(paste0(DIR_BASE, studyAreas[i], "\\Processing\\AP\\APFusion.bat"))){
		print(paste0(studyAreas[i], " doesn't exist")); flush.console()
	}
}




studyAreas[1]
#Run the first study area
if(!file.exists(paste0(DIR_BASE, studyAreas[1], "\\Products\\CanopyHeight_1p0METERS\\CHM_filled_3x_smoothed_1p0METERS.dtm"))){
	shell(
		paste0(DIR_BASE, studyAreas[1], "\\Processing\\AP\\APFusion.bat")
	)
}
#Run the other ones
for(i in 2:length(studyAreas)){
	#while the previous study area isn't finished, wait 10 minutes
	#while(!file.exists(paste0(DIR_BASE, studyAreas[i-1], "\\Products\\CanopyHeight_1p0METERS\\CHM_filled_3x_smoothed_1p0METERS.dtm"))){
	while(!file.exists(paste0(DIR_BASE, studyAreas[i-1], "\\Products\\Metrics_30METERS\\ALL_RETURNS_elev_AAD_2plus_30METERS.asc"))){
		Sys.sleep(60*10)
	}
	#Now that the previous study area exists, run the nex APFusion batch file
	#BUT first check that it needs to be run
#	if(!file.exists(paste0(DIR_BASE, studyAreas[i], "\\Products\\CanopyHeight_1p0METERS\\CHM_filled_3x_smoothed_1p0METERS.dtm"))){
	if(!file.exists(paste0(DIR_BASE, studyAreas[i], "\\Products\\Metrics_30METERS\\ALL_RETURNS_elev_AAD_2plus_30METERS.asc"))){
		shell(
			paste0(DIR_BASE, studyAreas[i], "\\Processing\\AP\\APFusion.bat")
		)
	}
}


