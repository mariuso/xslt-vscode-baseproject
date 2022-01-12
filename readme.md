# XSLT Transformation base project

This is a base project for XSLT transformations in Visual Studio Code.

## Requirements:
* [Visual Studio Code](https://code.visualstudio.com/)
* [Java 1.8 or later](https://adoptopenjdk.net/installation.html)
  * Direct download - [OpenJDK 11U - JDK x64 MSI](https://github.com/adoptium/temurin11-binaries/releases/download/jdk-11.0.13%2B8/OpenJDK11U-jdk_x64_windows_hotspot_11.0.13_8.msi)
* [Saxon-HE (Java)](https://sourceforge.net/projects/saxon/files/Saxon-HE/10/Java/)
  * Direct download - [Saxon HE10 6J ZIP](https://sourceforge.net/projects/saxon/files/Saxon-HE/10/Java/SaxonHE10-6J.zip/download)
* [XSLT/XPath for Visual Studio Code](https://marketplace.visualstudio.com/items?itemName=deltaxml.xslt-xpath)

## Installation of XSLT processor
[Installation Guide](https://deltaxml.github.io/vscode-xslt-xpath/run-xslt.html)

### Windows 
* Install Visual Studio Code
* Add XSLT/XPath for Visual Studio Code extenstion

#### Java
* Follow the Windows MSI-installer

#### Saxon
* Unzip the Saxon HE file
* Move the files to a fitting location
  * C:\Program Files\Saxon\
* Open Visual Studio Code Settings -> search "@ext:deltaxml.xslt-xpath"
* Update the Saxon HE Jar (Path of the installed Saxon jar file)
  * i.e. C:\Program Files\Saxon\saxon-he-10.6.jar

## XSLT processing
### .vscode/tasks.json
This file contains the settings for the 

### Running XSLT processor
(Shortcut cmd + shift + b / ctrl + shift + b)

* Open XSLT file you want use
* Open tasks
  * (cmd + P / ctrl + P) - To open command palette
  * Select: "Tasks - Run task"
* Run task: "xslt: Saxon Transform (New)"

You will be prompted to input the filename you want to run. Default set to **"testfiles/original.xml"**

### Default XML filename
You can customize the default filename and location by changing the inputs.default in **.vscode/tasks.json**