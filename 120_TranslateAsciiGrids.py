
#Name:	        120_TranslateAsciiGrids.py
#Author:	PA Fekety, AJ Poznanovic
#Purpose:	Translates the FUSION outputs (AsciiGrids) by 3000 meters, thus removing
#		the false easting. Generate a projection file for the AsciiGrids.
#Date:	        2015.09.22


#2015.09.22     New
#2016.02.10     Added lidar units, primarily from NPC-NF flown in 2015 
#2016.08.16	Moved scripts from CMS\N_ID_Imputation\Scripts to CMS\LidarData\Scripts
#               Renamed as script 05_XXX.py
#2016.08.19     Renamed script as 07_TranslateAsciiGrids.py (formerlly was 05_TranslateAsciiGrids.py)
#2016.09.09     Renamed script as 09_TranslateAsciiGrids.py (formerlly was 07_TranslateAsciiGrids.py)
#               I have been rerunning FUSION with new file structure, therefore I reorganized this script
#               and reran everything
#2017.02.13     Running script on FUSION Area Processor results
#2018.03.20		Renamed script as G:\FR\MFalkows-VMStorage\Patrick\CMS\LidarMetrics\epsg5071_Trans\FusionAP\_ProcessingScripts\120_TranslateAsciiGrids.py
#				formally (G:\FR\MFalkows-VMStorage\Patrick\CMS\LidarMetrics\050_TranslateAsciiGrids.py)
#				Added IPNF2016 lidar units

#AP assisted with the code to read the .ASC, change the xllcorner (line 3 of .ASC), and rewrite the .ASC

##Aaron J. Poznanovic, GISP
##Research Fellow | Department of Forest Resources | University of Minnesota
##Principal Consultant | Red Fox GIS & Remote Sensing | www.redfoxgis.com
##(218) 387-4050


#########################################################

"""
This script alters the third line in an ascii file and writes to a new ascii file
"""

#Establish Variables, import modules, ...
import os

# Change this to suit your needs
false_easting = 3000000


#Projection File in LandTrendr CRS
coords_LT = 'PROJCS["North_American_1983_Albers",GEOGCS["GCS_North_American_1983",DATUM["D_North_American_1983",SPHEROID["GRS_1980",6378137.0,298.257222101]],PRIMEM["Greenwich",0.0],UNIT["Degree",0.0174532925199433]],PROJECTION["Albers"],PARAMETER["false_easting",0.0],PARAMETER["false_northing",0.0],PARAMETER["central_meridian",-96.0],PARAMETER["standard_parallel_1",29.5],PARAMETER["standard_parallel_2",45.5],PARAMETER["latitude_of_origin",23.0],UNIT["Meter",1.0]]'


DIR_Trans = r'G:\FR\MFalkows-VMStorage\Patrick\CMS\LidarMetrics\epsg5071_Trans\FusionAP'
DIR_UnTrans = r'G:\FR\MFalkows-VMStorage\Patrick\CMS\LidarMetrics\epsg5071\FusionAP'

#-----------------------
#-----------------------
#Define Functions
#-----------------------
#-----------------------


#==============================================================================

#Purpose:
#   Remove the false easting from the FUSION metrics. Final grids should be in the same CRS as LandTrendr data
#   Write a projection file for the Fusion metric
#Input:
#   FP_grid (str) - the file path to the .ASC grids (FUSION outputs)
#Output:
#   Ascii grid (.asc)
#   Projection file (.prj)

def removeFalseEasting(StudyArea, DIR_Trans, DIR_UnTrans):
    
    #These are the grids to be processed
    FP_InMetrics = os.path.join(DIR_Trans, StudyArea, "Products", "Metrics_30METERS")
    FP_InCanopy =  os.path.join(DIR_Trans, StudyArea, "Products", "CanopyMetrics_30METERS")
    FP_InStrata =  os.path.join(DIR_Trans, StudyArea, "Products", "StrataMetrics_30METERS")
    
    #Create a direcotry to the translated rasters
    if not (os.path.exists(os.path.join(DIR_UnTrans, StudyArea))):
        os.mkdir(os.path.join(DIR_UnTrans, StudyArea))
    if not (os.path.exists(os.path.join(DIR_UnTrans, StudyArea, "Products"))):
        os.mkdir(os.path.join(DIR_UnTrans, StudyArea, "Products"))
    if not (os.path.exists(os.path.join(DIR_UnTrans, StudyArea, "Products", "Metrics_30METERS"))):
        os.mkdir(os.path.join(DIR_UnTrans, StudyArea, "Products", "Metrics_30METERS"))
    if not (os.path.exists(os.path.join(DIR_UnTrans, StudyArea, "Products", "CanopyMetrics_30METERS"))):
        os.mkdir(os.path.join(DIR_UnTrans, StudyArea, "Products", "CanopyMetrics_30METERS"))
    if not (os.path.exists(os.path.join(DIR_UnTrans, StudyArea, "Products", "StrataMetrics_30METERS"))):
        os.mkdir(os.path.join(DIR_UnTrans, StudyArea, "Products", "StrataMetrics_30METERS"))
        
    #First, write the Grid Metrics
    files = os.listdir(FP_InMetrics)# + os.listdir(FP_InCanopy)    
    grids = []
    for grid in files:
        if grid[-4:] == '.asc':
            grids.append(grid)
    grids.sort()
    
    
    for grid in grids:
        #file path of the grid being processed
        txt = os.path.join(FP_InMetrics, grid)
        
        # Read in the grid, remove the false easting
        # Open the txt file
        with open(txt, 'r') as f:
            lines = [] # Create an empty list to append lines to
            for i, line in enumerate(f):
                if i == 2: # This is the 3rd line in header
                    l = repr(line.strip())
                    #Note that you may need to reformat this ("new") line for your purposes
                    new = "xllcorner " + str(float(l.split(" ")[1][:-1]) - false_easting) + "\n"
                    lines.append(new) # Write "new" to list
                else:
                    # Otherwise write all of the other lines as is
                    lines.append(str(line))
        
        
        # Write to ascii file again
        with open(os.path.join(DIR_UnTrans, StudyArea, "Products", "Metrics_30METERS", grid), 'w') as f:
            f.writelines("%s" % l for l in lines)
        
        # Write the projection file
        prj = os.path.join(os.path.join(DIR_UnTrans, StudyArea, "Products", "Metrics_30METERS", grid[:-4] + '.prj'))
        with open(prj, 'w') as f:
            f.writelines(coords_LT)
    
    #Second, write the Canopy Metrics
    files =  os.listdir(FP_InCanopy)    
    grids = []
    for grid in files:
        if grid[-4:] == '.asc':
            grids.append(grid)
    grids.sort()
    
    for grid in grids:
        #file path of the grid being processed
        txt = os.path.join(FP_InCanopy, grid)
        
        
        # Read in the grid, remove the false easting
        # Open the txt file
        with open(txt, 'r') as f:
            lines = [] # Create an empty list to append lines to
            for i, line in enumerate(f):
                if i == 2: # This is the 3rd line in header
                    l = repr(line.strip())
                    #Note that you may need to reformat this ("new") line for your purposes
                    new = "xllcorner " + str(float(l.split(" ")[1][:-1]) - false_easting) + "\n"
                    lines.append(new) # Write "new" to list
                else:
                    # Otherwise write all of the other lines as is
                    lines.append(str(line))
        
        
        # Write to ascii file again
        with open(os.path.join(DIR_UnTrans, StudyArea, "Products", "CanopyMetrics_30METERS", grid), 'w') as f:
            f.writelines("%s" % l for l in lines)
        
        # Write the projection file
        prj = os.path.join(os.path.join(DIR_UnTrans, StudyArea, "Products", "CanopyMetrics_30METERS", grid[:-4] + '.prj'))
        with open(prj, 'w') as f:
            f.writelines(coords_LT)
    
    #Third, write the Strata Metrics
    files =  os.listdir(FP_InStrata)    
    grids = []
    for grid in files:
        if grid[-4:] == '.asc':
            grids.append(grid)
    grids.sort()
    
    for grid in grids:
        #file path of the grid being processed
        txt = os.path.join(FP_InStrata, grid)
        
        
        # Read in the grid, remove the false easting
        # Open the txt file
        with open(txt, 'r') as f:
            lines = [] # Create an empty list to append lines to
            for i, line in enumerate(f):
                if i == 2: # This is the 3rd line in header
                    l = repr(line.strip())
                    #Note that you may need to reformat this ("new") line for your purposes
                    new = "xllcorner " + str(float(l.split(" ")[1][:-1]) - false_easting) + "\n"
                    lines.append(new) # Write "new" to list
                else:
                    # Otherwise write all of the other lines as is
                    lines.append(str(line))
        
        
        # Write to ascii file again
        with open(os.path.join(DIR_UnTrans, StudyArea, "Products", "StrataMetrics_30METERS", grid), 'w') as f:
            f.writelines("%s" % l for l in lines)
        
        # Write the projection file
        prj = os.path.join(os.path.join(DIR_UnTrans, StudyArea, "Products", "StrataMetrics_30METERS", grid[:-4] + '.prj'))
        with open(prj, 'w') as f:
            f.writelines(coords_LT)




#-----------------------
#-----------------------
#Remove the false easting
#-----------------------
#-----------------------

'''
#Comment out after running!!
'''
##removeFalseEasting(StudyArea="AmericanFalls", DIR_Trans=DIR_Trans, DIR_UnTrans=DIR_UnTrans)
##removeFalseEasting(StudyArea="Bannock", DIR_Trans=DIR_Trans, DIR_UnTrans=DIR_UnTrans)
##removeFalseEasting(StudyArea="BigSandCreek", DIR_Trans=DIR_Trans, DIR_UnTrans=DIR_UnTrans)
##removeFalseEasting(StudyArea="BigWoodOLC2015North", DIR_Trans=DIR_Trans, DIR_UnTrans=DIR_UnTrans)
##removeFalseEasting(StudyArea="BigWoodOLC2015South", DIR_Trans=DIR_Trans, DIR_UnTrans=DIR_UnTrans)
##removeFalseEasting(StudyArea="BirdsOfPrey2011", DIR_Trans=DIR_Trans, DIR_UnTrans=DIR_UnTrans)
##removeFalseEasting(StudyArea="Blackfoot", DIR_Trans=DIR_Trans, DIR_UnTrans=DIR_UnTrans)
##removeFalseEasting(StudyArea="BoiseRiver2015", DIR_Trans=DIR_Trans, DIR_UnTrans=DIR_UnTrans)
##removeFalseEasting(StudyArea="BorahScarp2005", DIR_Trans=DIR_Trans, DIR_UnTrans=DIR_UnTrans)
##removeFalseEasting(StudyArea="BoxCanyon", DIR_Trans=DIR_Trans, DIR_UnTrans=DIR_UnTrans)
##removeFalseEasting(StudyArea="BuckHolland", DIR_Trans=DIR_Trans, DIR_UnTrans=DIR_UnTrans)
##removeFalseEasting(StudyArea="BullTroutLake", DIR_Trans=DIR_Trans, DIR_UnTrans=DIR_UnTrans)
##removeFalseEasting(StudyArea="CamasNWR", DIR_Trans=DIR_Trans, DIR_UnTrans=DIR_UnTrans)
##removeFalseEasting(StudyArea="CityOfKuna2015", DIR_Trans=DIR_Trans, DIR_UnTrans=DIR_UnTrans)
##removeFalseEasting(StudyArea="ClearCreek", DIR_Trans=DIR_Trans, DIR_UnTrans=DIR_UnTrans)
##removeFalseEasting(StudyArea="Clearwater", DIR_Trans=DIR_Trans, DIR_UnTrans=DIR_UnTrans)
##removeFalseEasting(StudyArea="CoeurDAleneRiver", DIR_Trans=DIR_Trans, DIR_UnTrans=DIR_UnTrans)
##removeFalseEasting(StudyArea="ColtBertha", DIR_Trans=DIR_Trans, DIR_UnTrans=DIR_UnTrans)
##removeFalseEasting(StudyArea="ColumbiaRiverTreaty_D5_UTM11_ID", DIR_Trans=DIR_Trans, DIR_UnTrans=DIR_UnTrans)
##removeFalseEasting(StudyArea="ColvilleNF2012", DIR_Trans=DIR_Trans, DIR_UnTrans=DIR_UnTrans)
##removeFalseEasting(StudyArea="ColvilleNF2014", DIR_Trans=DIR_Trans, DIR_UnTrans=DIR_UnTrans)
##removeFalseEasting(StudyArea="CoolMush", DIR_Trans=DIR_Trans, DIR_UnTrans=DIR_UnTrans)
##removeFalseEasting(StudyArea="CorralHogMeadowCreekPotlatchRiver", DIR_Trans=DIR_Trans, DIR_UnTrans=DIR_UnTrans)
##removeFalseEasting(StudyArea="CougarLeggett", DIR_Trans=DIR_Trans, DIR_UnTrans=DIR_UnTrans)
##removeFalseEasting(StudyArea="CoveRestoration", DIR_Trans=DIR_Trans, DIR_UnTrans=DIR_UnTrans)
##removeFalseEasting(StudyArea="CrookedRiver", DIR_Trans=DIR_Trans, DIR_UnTrans=DIR_UnTrans)
##removeFalseEasting(StudyArea="Dalton", DIR_Trans=DIR_Trans, DIR_UnTrans=DIR_UnTrans)
##removeFalseEasting(StudyArea="DaltonB", DIR_Trans=DIR_Trans, DIR_UnTrans=DIR_UnTrans)
##removeFalseEasting(StudyArea="DCEF2011", DIR_Trans=DIR_Trans, DIR_UnTrans=DIR_UnTrans)
##removeFalseEasting(StudyArea="Damon", DIR_Trans=DIR_Trans, DIR_UnTrans=DIR_UnTrans)
##removeFalseEasting(StudyArea="DryCreek2007", DIR_Trans=DIR_Trans, DIR_UnTrans=DIR_UnTrans)
##removeFalseEasting(StudyArea="DryCreek2009", DIR_Trans=DIR_Trans, DIR_UnTrans=DIR_UnTrans)
##removeFalseEasting(StudyArea="DutchOven", DIR_Trans=DIR_Trans, DIR_UnTrans=DIR_UnTrans)
##removeFalseEasting(StudyArea="ElkCity", DIR_Trans=DIR_Trans, DIR_UnTrans=DIR_UnTrans)
##removeFalseEasting(StudyArea="EmeraldCreek", DIR_Trans=DIR_Trans, DIR_UnTrans=DIR_UnTrans)
##removeFalseEasting(StudyArea="Fernan", DIR_Trans=DIR_Trans, DIR_UnTrans=DIR_UnTrans)
##removeFalseEasting(StudyArea="FrenchCreekPreacherNorthForkFront", DIR_Trans=DIR_Trans, DIR_UnTrans=DIR_UnTrans)
##removeFalseEasting(StudyArea="Grangeville", DIR_Trans=DIR_Trans, DIR_UnTrans=DIR_UnTrans)
##removeFalseEasting(StudyArea="HeadwatersPalouse", DIR_Trans=DIR_Trans, DIR_UnTrans=DIR_UnTrans)
##removeFalseEasting(StudyArea="HemlockElk", DIR_Trans=DIR_Trans, DIR_UnTrans=DIR_UnTrans)
##removeFalseEasting(StudyArea="HenrysFork", DIR_Trans=DIR_Trans, DIR_UnTrans=DIR_UnTrans)
##removeFalseEasting(StudyArea="Hollister2010", DIR_Trans=DIR_Trans, DIR_UnTrans=DIR_UnTrans)
##removeFalseEasting(StudyArea="HUC10Addition", DIR_Trans=DIR_Trans, DIR_UnTrans=DIR_UnTrans)
##removeFalseEasting(StudyArea="ISUPocatello", DIR_Trans=DIR_Trans, DIR_UnTrans=DIR_UnTrans)
##removeFalseEasting(StudyArea="JackWaite", DIR_Trans=DIR_Trans, DIR_UnTrans=DIR_UnTrans)
##removeFalseEasting(StudyArea="JuniperTransect", DIR_Trans=DIR_Trans, DIR_UnTrans=DIR_UnTrans)
#removeFalseEasting(StudyArea="Kamiah", DIR_Trans=DIR_Trans, DIR_UnTrans=DIR_UnTrans)
##removeFalseEasting(StudyArea="LaundryChinaOsier", DIR_Trans=DIR_Trans, DIR_UnTrans=DIR_UnTrans)
##removeFalseEasting(StudyArea="LemhiRiver2008", DIR_Trans=DIR_Trans, DIR_UnTrans=DIR_UnTrans)
##removeFalseEasting(StudyArea="LemhiRiver2010", DIR_Trans=DIR_Trans, DIR_UnTrans=DIR_UnTrans)
##removeFalseEasting(StudyArea="LemhiRiver2011", DIR_Trans=DIR_Trans, DIR_UnTrans=DIR_UnTrans)
##removeFalseEasting(StudyArea="LemhiRiverAmonson2008", DIR_Trans=DIR_Trans, DIR_UnTrans=DIR_UnTrans)
##removeFalseEasting(StudyArea="LemhiSubbasin2008", DIR_Trans=DIR_Trans, DIR_UnTrans=DIR_UnTrans)
##removeFalseEasting(StudyArea="LoloCreekElDoradoCreek", DIR_Trans=DIR_Trans, DIR_UnTrans=DIR_UnTrans)
#removeFalseEasting(StudyArea="LowerCottonwood", DIR_Trans=DIR_Trans, DIR_UnTrans=DIR_UnTrans)
##removeFalseEasting(StudyArea="LowerLochsa", DIR_Trans=DIR_Trans, DIR_UnTrans=DIR_UnTrans)
##removeFalseEasting(StudyArea="LowerMonture", DIR_Trans=DIR_Trans, DIR_UnTrans=DIR_UnTrans)
##removeFalseEasting(StudyArea="LowerMorell", DIR_Trans=DIR_Trans, DIR_UnTrans=DIR_UnTrans)
##removeFalseEasting(StudyArea="LowerTrail", DIR_Trans=DIR_Trans, DIR_UnTrans=DIR_UnTrans)
##removeFalseEasting(StudyArea="MeadowCreek", DIR_Trans=DIR_Trans, DIR_UnTrans=DIR_UnTrans)
##removeFalseEasting(StudyArea="MeadowCreekAddition", DIR_Trans=DIR_Trans, DIR_UnTrans=DIR_UnTrans)
##removeFalseEasting(StudyArea="MeadowSmith", DIR_Trans=DIR_Trans, DIR_UnTrans=DIR_UnTrans)
##removeFalseEasting(StudyArea="Middleton2011", DIR_Trans=DIR_Trans, DIR_UnTrans=DIR_UnTrans)
##removeFalseEasting(StudyArea="MillCreekHungryRidge", DIR_Trans=DIR_Trans, DIR_UnTrans=DIR_UnTrans)
##removeFalseEasting(StudyArea="MontureCreek", DIR_Trans=DIR_Trans, DIR_UnTrans=DIR_UnTrans)
##removeFalseEasting(StudyArea="MoscowMtn2003", DIR_Trans=DIR_Trans, DIR_UnTrans=DIR_UnTrans)
##removeFalseEasting(StudyArea="MoscowMtn2007", DIR_Trans=DIR_Trans, DIR_UnTrans=DIR_UnTrans)
##removeFalseEasting(StudyArea="MoscowMtn2009", DIR_Trans=DIR_Trans, DIR_UnTrans=DIR_UnTrans)
##removeFalseEasting(StudyArea="Musselshell", DIR_Trans=DIR_Trans, DIR_UnTrans=DIR_UnTrans)
#removeFalseEasting(StudyArea="NezPerce", DIR_Trans=DIR_Trans, DIR_UnTrans=DIR_UnTrans)
##removeFalseEasting(StudyArea="NorthLake", DIR_Trans=DIR_Trans, DIR_UnTrans=DIR_UnTrans)
##removeFalseEasting(StudyArea="NorthSwan", DIR_Trans=DIR_Trans, DIR_UnTrans=DIR_UnTrans)
##removeFalseEasting(StudyArea="Pahsimeroi", DIR_Trans=DIR_Trans, DIR_UnTrans=DIR_UnTrans)
##removeFalseEasting(StudyArea="PalouseAddition1", DIR_Trans=DIR_Trans, DIR_UnTrans=DIR_UnTrans)
##removeFalseEasting(StudyArea="PalouseAddition2", DIR_Trans=DIR_Trans, DIR_UnTrans=DIR_UnTrans)
##removeFalseEasting(StudyArea="PalouseAddition3", DIR_Trans=DIR_Trans, DIR_UnTrans=DIR_UnTrans)
##removeFalseEasting(StudyArea="PayetteA2", DIR_Trans=DIR_Trans, DIR_UnTrans=DIR_UnTrans)
##removeFalseEasting(StudyArea="PayetteA3", DIR_Trans=DIR_Trans, DIR_UnTrans=DIR_UnTrans)
##removeFalseEasting(StudyArea="PayetteA4", DIR_Trans=DIR_Trans, DIR_UnTrans=DIR_UnTrans)
##removeFalseEasting(StudyArea="PayetteA6", DIR_Trans=DIR_Trans, DIR_UnTrans=DIR_UnTrans)
##removeFalseEasting(StudyArea="Pocatello2005", DIR_Trans=DIR_Trans, DIR_UnTrans=DIR_UnTrans)
##removeFalseEasting(StudyArea="Pocatello2010", DIR_Trans=DIR_Trans, DIR_UnTrans=DIR_UnTrans)
##removeFalseEasting(StudyArea="Potlatch", DIR_Trans=DIR_Trans, DIR_UnTrans=DIR_UnTrans)
##removeFalseEasting(StudyArea="Powell", DIR_Trans=DIR_Trans, DIR_UnTrans=DIR_UnTrans)
##removeFalseEasting(StudyArea="PREF2002", DIR_Trans=DIR_Trans, DIR_UnTrans=DIR_UnTrans)
##removeFalseEasting(StudyArea="PREF2011", DIR_Trans=DIR_Trans, DIR_UnTrans=DIR_UnTrans)
##removeFalseEasting(StudyArea="Priest2012", DIR_Trans=DIR_Trans, DIR_UnTrans=DIR_UnTrans)
##removeFalseEasting(StudyArea="ReynoldsCreek2007", DIR_Trans=DIR_Trans, DIR_UnTrans=DIR_UnTrans)
##removeFalseEasting(StudyArea="ReynoldsCreek2009", DIR_Trans=DIR_Trans, DIR_UnTrans=DIR_UnTrans)
##removeFalseEasting(StudyArea="Rice", DIR_Trans=DIR_Trans, DIR_UnTrans=DIR_UnTrans)
##removeFalseEasting(StudyArea="Richmond", DIR_Trans=DIR_Trans, DIR_UnTrans=DIR_UnTrans)
##removeFalseEasting(StudyArea="RigginsWestIsland", DIR_Trans=DIR_Trans, DIR_UnTrans=DIR_UnTrans)
##removeFalseEasting(StudyArea="SalmonFalls2002", DIR_Trans=DIR_Trans, DIR_UnTrans=DIR_UnTrans)
##removeFalseEasting(StudyArea="SalmonFalls2005", DIR_Trans=DIR_Trans, DIR_UnTrans=DIR_UnTrans)
##removeFalseEasting(StudyArea="SalmonFalls2010", DIR_Trans=DIR_Trans, DIR_UnTrans=DIR_UnTrans)
##removeFalseEasting(StudyArea="SawtoothNorth", DIR_Trans=DIR_Trans, DIR_UnTrans=DIR_UnTrans)
##removeFalseEasting(StudyArea="SawtoothSouth", DIR_Trans=DIR_Trans, DIR_UnTrans=DIR_UnTrans)
##removeFalseEasting(StudyArea="SelwayRiverElkCreek", DIR_Trans=DIR_Trans, DIR_UnTrans=DIR_UnTrans)
##removeFalseEasting(StudyArea="SheepStation2002", DIR_Trans=DIR_Trans, DIR_UnTrans=DIR_UnTrans)
##removeFalseEasting(StudyArea="SheepStationPostFire2005", DIR_Trans=DIR_Trans, DIR_UnTrans=DIR_UnTrans)
##removeFalseEasting(StudyArea="ShotgunCreek", DIR_Trans=DIR_Trans, DIR_UnTrans=DIR_UnTrans)
##removeFalseEasting(StudyArea="SlateCreek", DIR_Trans=DIR_Trans, DIR_UnTrans=DIR_UnTrans)
##removeFalseEasting(StudyArea="SmithCreek", DIR_Trans=DIR_Trans, DIR_UnTrans=DIR_UnTrans)
##removeFalseEasting(StudyArea="SnakeRiver2011", DIR_Trans=DIR_Trans, DIR_UnTrans=DIR_UnTrans)
##removeFalseEasting(StudyArea="SnakeRiver2011HeiseRoad", DIR_Trans=DIR_Trans, DIR_UnTrans=DIR_UnTrans)
##removeFalseEasting(StudyArea="SnakeRiverOLC2015", DIR_Trans=DIR_Trans, DIR_UnTrans=DIR_UnTrans)
##removeFalseEasting(StudyArea="SouthForkSalmon", DIR_Trans=DIR_Trans, DIR_UnTrans=DIR_UnTrans)
##removeFalseEasting(StudyArea="SouthMountain2007", DIR_Trans=DIR_Trans, DIR_UnTrans=DIR_UnTrans)
##removeFalseEasting(StudyArea="Stanley", DIR_Trans=DIR_Trans, DIR_UnTrans=DIR_UnTrans)
##removeFalseEasting(StudyArea="Stemple", DIR_Trans=DIR_Trans, DIR_UnTrans=DIR_UnTrans)
##removeFalseEasting(StudyArea="StJoe", DIR_Trans=DIR_Trans, DIR_UnTrans=DIR_UnTrans)
##removeFalseEasting(StudyArea="Stonewall", DIR_Trans=DIR_Trans, DIR_UnTrans=DIR_UnTrans)
##removeFalseEasting(StudyArea="SwanValley2002", DIR_Trans=DIR_Trans, DIR_UnTrans=DIR_UnTrans)
##removeFalseEasting(StudyArea="TenTwentyMile", DIR_Trans=DIR_Trans, DIR_UnTrans=DIR_UnTrans)
##removeFalseEasting(StudyArea="TepeePotterCreek", DIR_Trans=DIR_Trans, DIR_UnTrans=DIR_UnTrans)
##removeFalseEasting(StudyArea="Teton", DIR_Trans=DIR_Trans, DIR_UnTrans=DIR_UnTrans)
##removeFalseEasting(StudyArea="ThunderMountain", DIR_Trans=DIR_Trans, DIR_UnTrans=DIR_UnTrans)
##removeFalseEasting(StudyArea="TwinCreek", DIR_Trans=DIR_Trans, DIR_UnTrans=DIR_UnTrans)
##removeFalseEasting(StudyArea="UpperElk", DIR_Trans=DIR_Trans, DIR_UnTrans=DIR_UnTrans)
##removeFalseEasting(StudyArea="UpperLoloCreek", DIR_Trans=DIR_Trans, DIR_UnTrans=DIR_UnTrans)
##removeFalseEasting(StudyArea="UpperWarren", DIR_Trans=DIR_Trans, DIR_UnTrans=DIR_UnTrans)
##removeFalseEasting(StudyArea="ValleyCountyID", DIR_Trans=DIR_Trans, DIR_UnTrans=DIR_UnTrans)
##removeFalseEasting(StudyArea="WaldePeteKing", DIR_Trans=DIR_Trans, DIR_UnTrans=DIR_UnTrans)
##removeFalseEasting(StudyArea="WeiserRiver", DIR_Trans=DIR_Trans, DIR_UnTrans=DIR_UnTrans)
##removeFalseEasting(StudyArea="WestFlesher", DIR_Trans=DIR_Trans, DIR_UnTrans=DIR_UnTrans)
##removeFalseEasting(StudyArea="Woodward", DIR_Trans=DIR_Trans, DIR_UnTrans=DIR_UnTrans)


##removeFalseEasting(StudyArea="ColvilleNFEast2015", DIR_Trans=DIR_Trans, DIR_UnTrans=DIR_UnTrans)
##removeFalseEasting(StudyArea="ColvilleNFWest2015", DIR_Trans=DIR_Trans, DIR_UnTrans=DIR_UnTrans)

#2018.03.20
##removeFalseEasting(StudyArea="American2016", DIR_Trans=DIR_Trans, DIR_UnTrans=DIR_UnTrans)
##removeFalseEasting(StudyArea="BallTrout2016", DIR_Trans=DIR_Trans, DIR_UnTrans=DIR_UnTrans)
##removeFalseEasting(StudyArea="BinarchCreek2016", DIR_Trans=DIR_Trans, DIR_UnTrans=DIR_UnTrans)
##removeFalseEasting(StudyArea="BuckskinSaddle2016", DIR_Trans=DIR_Trans, DIR_UnTrans=DIR_UnTrans)
##removeFalseEasting(StudyArea="BuncoRoushRossi2016", DIR_Trans=DIR_Trans, DIR_UnTrans=DIR_UnTrans)
##removeFalseEasting(StudyArea="CampDawson2016", DIR_Trans=DIR_Trans, DIR_UnTrans=DIR_UnTrans)
##removeFalseEasting(StudyArea="CowGrassCreekAllotments2016", DIR_Trans=DIR_Trans, DIR_UnTrans=DIR_UnTrans)
##removeFalseEasting(StudyArea="Emerald2016", DIR_Trans=DIR_Trans, DIR_UnTrans=DIR_UnTrans)
##removeFalseEasting(StudyArea="FishhookHomestead2016", DIR_Trans=DIR_Trans, DIR_UnTrans=DIR_UnTrans)
##removeFalseEasting(StudyArea="Glover2016", DIR_Trans=DIR_Trans, DIR_UnTrans=DIR_UnTrans)
##removeFalseEasting(StudyArea="LacyLamoosh2016", DIR_Trans=DIR_Trans, DIR_UnTrans=DIR_UnTrans)
##removeFalseEasting(StudyArea="QuartzUpperJoe2016", DIR_Trans=DIR_Trans, DIR_UnTrans=DIR_UnTrans)
##removeFalseEasting(StudyArea="Slate2016", DIR_Trans=DIR_Trans, DIR_UnTrans=DIR_UnTrans)

