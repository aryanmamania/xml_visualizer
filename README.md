# User Manual - Automated XML to HTML Diagram Generator

## Overview

This document serves as a user manual for clients who will use one of the two provided automated scripts to generate visual HTML diagrams from Camel-based XML files. The scripts install necessary tools, run Docker containers, process XML files, and host the output on a browser-based interface.

---

## Requirements

Before running the script, ensure the following:

- **System**: Ubuntu 20.04+ or any Debian-based Linux
- **Internet access**: Required for Docker installation and pulling image
- **Git**: Must be installed (for cloning the repository)
- **Terminal access**

---

## Clone the Repository

Open your terminal and run:

- `https://github.com/aryanmamania/xml_visualizer.git` – (This command downloads the entire visualizer project from GitHub to your local machine)
- `cd xml_visualizer` – (This command moves you into the downloaded project folder so you can run the scripts inside it.)

> Use **Any one script** based on your use case. Both are automated and independent.

---

Once inside the folder where the script (`route_visualizer.sh` or `setup_diagram_service.sh`) is located, proceed with the execution steps below.

---

## 🔧 Option 1: `route_visualizer.sh` (Simple nginx-Based Viewer)

### Step 1: Run the Script

```bash
bash route_visualizer.sh
```
### Step 2: Go to the Home Directory

```bash
cd  (You will be inside your home directory, where an route-visualizer/ folder will be created automatically)
```

### Step 3: Verify Folder Creation

```bash
cd ~/route-visualizer/input
```

### Step 4: Add and Verify XML

```bash
cp yourfile.xml ~/route-visualizer/input/
```

- Wait **5–10 seconds**
- Open browser: [http://localhost:8001/visualizer/index.html](http://localhost:8001/visualizer/index.html)
- 🔄 **Refresh browser** to load the new file
- It will ask for username and password — use admin / admin
- ✅ **You should see your service and route in the diagram**

---

## 🔧 Option 2: `setup_diagram_service.sh` (Simple Apache-Based Viewer)


### Step 1: Run the Script

```bash
bash setup_diagram_service.sh
```
- A new folder called input will be created 

### Step 2: Verify Folder Creation

```bash
ls -ltr input/
```

### Step 3: Add and Verify XML

```bash
cp yourfile.xml input/
```

- Wait **5–10 seconds**
- Open browser: [http://localhost:9003/](http://localhost:9003/)
- 🔄 **Refresh browser** to load the new file
- ✅ **You should see your service and route in the diagram**

> ✅ This process confirms that your setup is working and that the input XML is being correctly parsed and visualized.
