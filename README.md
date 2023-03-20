# FLSbagfile
The software of this repository creates a bag file that describe the flight path of FLSs to render an illumination.  A Flying Light Speck, FLS, is a miniature sized drone configured with light sources.  Swarms of FLSs will illuminate an object in a 3D volume, an FLS display.  Computing the flight path of FLSs to render an illumination is both computationally expensive and time consuming.  This repository contains MATLAB software to store these flight paths in a bag file.  These bag files may be used in simulation studies (e.g., AirSim, Gazebo) that investigate alternative architectures for an FLS display, lighting designs for FLSs and their rendering of different scenes, and algorithms for FLS failure handling and battery charging.

Authors:  Hamed Alimohammadzadeh (halimoha@usc.edu), Daryon Mehraban (daryonm@gmail.com), Shahram Ghandeharizadeh (shahram@usc.edu)

This software was developed using MATLAB R2022b for academic use.

# Features

  * Store the flight paths of FLSs to illuminate a motion illumination in a bag file. 
  * Retrieve a specific point cloud of a sequence that constitutes a scene. 
  * Retrieve a specific scene.
  * Retrieve a range of point clouds in a sequence that constitutes a scene.
  * Retrieve a point cloud given its id in a sequence that constitutes a scene.
  * Data folder contains a bag file pertaining to the [rose clip](https://youtu.be/zaZwAiCsZUU) consisting of 115 point clouds.

# Limitations
To generate a bag file, the in-memory representation of FLS flight paths must adhere to the format described in Create a Bag File below.  This is the only format we are aware of given the novely of FLSs and their displays.  We will extend this repository with additional in-memory formats for FLS flight paths as they become available.  

# Getting the Source
```bash
git clone https://github.com/shahramg/FLSbagfiles
```

# Environment
Install MATLAB with support for ROS.   

Launch MATLAB from the directory that contains FLSbagfiles.
Initialize ROS by issuing the following command in the command line:
```bash
rosinit
```

Generate the fls message types by issuing the following command in the MATLAB command line:
```
rosgenmsg('./ROSpackages/')
```
Depending on your operating system (MacOS, Windows), you may be required to add custom message folder to the MATLAB path by executing:
```
addpath('/Users/shahramghandeharizadeh/Documents/src/FLSbagfile/ROSpackages/matlab_msg_gen_ros1/maci64/install/m')
savepath
```

Verify the FLS message types are registered with ROS by issuing the following command and find 'flyinglightspeck/FLSElt' on this list.  
```
rosmsg list
```

If 'flyinglightspeck/FLSElt' does not exist on the list then consider re-setting the ROS message list and clearing its cache by issuing the following commands:
```
clear classes;
rehash toolboxcache;
```
Repeat the rosgenmsg command to register FLS message types with ROS.

Run the following test to verify the FLS required ROS messages have been created successfully.
```
runtests("FLSbagfileTest","ProcedureName","flsMessageType")
```
This test verifies the existence of the following custom message types in the MATLAB environment:  flyinglightspeck/FLSElt, flyinglightspeck/FLSLHD, flyinglightspeck/FLSDuration, flyinglightspeck/FLSRGBA.

# Create a Bag File
To create a bag file for FLS flight paths use the following command:
```
writeFlightPathToFile(FLSArray, Filename, Topic)
```
FLSArray is an in-memory formatting of the flight paths for each FLS.  Filename specifies the path for a bagfile.  Topic specifies the topic of the bag file which the messages will be written to.  They are used when the FLS flight paths are generated using a named communication channel, see [ROS Topics](https://wiki.ros.org/Topics) for details.

If the specified Filename exists then writeFlightPathToFile asks whether the Filename should be overwritten.

FLSArray is an array of arrays, see figure below.  Each array contains msgElt instances.  FLSArray{i} is the array of msgElt instances for FLS i.  There may be one or more instances for each FLS depending on its flight path.  The number of instances for each FLS may not exceed the number of point clouds in a sequence. 
![alt text](https://github.com/shahramg/FLSbagfile/blob/main/images/flsarray.png?raw=true)

Each msgElt consists of a coordClass, colorClass, and durationClass, see figure below.
![alt text](https://github.com/shahramg/FLSbagfile/blob/main/images/msgelt.png?raw=true)

The following unit test creates a scene contianing a sequence of deterministic point clouds and verifies the bag file representation is correct.
```
runtests("FLSbagfileTest","ProcedureName","retrievePointCloud")
```

The following unit test creates a scene contianing a sequence of deterministic point clouds and slices it. 
Subsequently, it verifies the sliced bag file representation is correct.
```
runtests("FLSbagfileTest","ProcedureName","sliceFlightPath")
```

These unit tests clean up after executing.  Hence, there are no residue files left on the file system.

# Unit Tests
There are three unit tests that were detailed in the previous sections.  To run all three, one after the other, issue the following command:
```
runtests("FLSbagfileTest")
```
The unit tests clean up after themselves, leaving no residual files behind.

# Citations

1. Hamed Alimohammadzadeh, Daryon Mehraban, and Shahram Ghandeharizadeh.  Modeling Illumination Data with Flying Light Specks.  Submitted for publication.

2. Shahram Ghandeharizadeh. 2022. Display of 3D Illuminations using Flying Light Specks.  In Proceedings of the 30th ACM International Conference on Multimedia} (MM '22), October 10--14, 2022, Lisboa, Portugal, DOI 10.1145/3503161.3548250, ISBN 978-1-4503-9203-7/22/10.

BibTex:
```
@inproceedings{10.1145/3503161.3548250,
author = {Ghandeharizadeh, Shahram},
title = {Display of 3D Illuminations using Flying Light Specks},
year = {2022},
isbn = {978-1-4503-9203-7/22/10},
publisher = {Association for Computing Machinery},
address = {New York, NY, USA},
doi = {10.1145/3503161.3548250},
booktitle = {ACM Multimedia},
location = {Lisboa, Portugal},
series = {MM '22}
}
```
