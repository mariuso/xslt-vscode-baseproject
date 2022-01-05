# XSLT Transformation base project

This is a base project for XSLT transformations in Visual Studio Code.

## Requirements:
* [Visual Studio Code](https://code.visualstudio.com/)
* [Java 1.8 or later](https://adoptopenjdk.net/installation.html)
* [Saxon-HE (Java)](https://sourceforge.net/projects/saxon/files/Saxon-HE/10/Java/)
* [XSLT/XPath for Visual Studio Code](https://marketplace.visualstudio.com/items?itemName=deltaxml.xslt-xpath)

## Installation of XSLT processor
[Installation Guide](https://deltaxml.github.io/vscode-xslt-xpath/run-xslt.html)

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