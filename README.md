# README #

This README is a preliminary draft for the instructions to setup and run the algorithm to use DIC and Feature registration to calculate strain in bone. Only the parts where the user will touch are documented at the moment, but an example test case is provided to assist in the usage of this program.

-----------------------

### What is this repository for? ###

This repository is designed to work with at least MatLab R2014b in terms of version. The critical function that prevents this program from being run on older versions is the activecontour() function.

Version: (Last Edited): July 31, 2016

-----------------------

### How do I get set up? ###

The main program is called "DIC_Scripting_for_Feature_Registration.m". A lot of documentation is placed there as well, so start off with looking at that first.

The only other file you probably want to look at is "zero_strain_rescan.m", which contains the fixed image and moving image file parameters to be registered and analyzed.

If you are interested in just using the DIC program, the visual GUI that came with it can be started from "DIC_GUI_May_01_2008.m". "script_DIC.m" provides an example of how to invoke the DIC program from script format.

### Running the Program ###

Just open "DIC_Scripting_for_Feature_Registration.m" and hit run for an example test case of measuring strain for a zero strain test case. The documentaion in the file will help you find out what parameters you need to change to suit your needs.

### Image Reading and Writing ###

Input images have to be present in both .raw (float32) format as well as .tif format. DIC uses the .tif format while the feature registration uses the ,raw (flaot32) format.

### Who do I talk to? ###
Repo Owner: Frankie (Hoi-Ki) Tong <frankietong@hotmail.com\>