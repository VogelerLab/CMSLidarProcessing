# CMSLidarProcessing
Lidar processing workflow used in Hudak’s CMS phase 1

These lidar scripts primarily rely on FUSION for processing. Some preprocessing might be necessary to get the data into the correct structure (e.g., the DTM format required for FUSION)

The workflow was developed using an older version of FUSION. Recent changes to FUSION might render some of these scripts decrepit. For example, applying the false easting.

Some other notes about this project
* The file paths refer to the computers being used at that time. 
* The folder name "_Blank_20170127" would be replaced by the lidar project name.
* 2017.01.27 was the last time a change was made to the file structure.
* Some of the FUSION batch files were altered.
* It is still necessary to initialize the FUSION AP GUI.
  * Set lower left corner of output rasters
  * Create AP Scripts