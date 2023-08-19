# AutoPerfmon
Automation tool that allows users to derive desired performance measurement results through perfmon, a performance measurement tool for Windows OS servers.


## Workflow
![image](https://github.com/JuYeon28/AutoPerfmon/assets/61408167/38db55b3-6a67-4402-9f85-0b87f5200ad0)




## Purpose of each file

### counterlist.json
It contains a list of major counters that can be measured on a Windows OS server.
The content of this file may be modified as necessary to obtain measurement results for desired performance counters.

### perfmon_exe.ps1
It is a file that executes perfmon, a performance measurement tool, according to the user's needs.
The perfmon is executed according to the target server, performance indicator, and measurement time value entered by the user.

### short_counter.py
Users can specify counters that want to be measured only with this python file without modifying the counter list in the counterlist.json.
The counterlist.json also has the role of a reference list for major performance counters, so it is not recommended to modify it.

### visualization.py
It is a file that measures the performance indicators of the target server desired by the user through the above files and then visualizes the result data as a graph.
The user may select and generate a file for the result graph from png or html.
It should be considered that the longer the measurement period entered, the longer the time required for the visualization process.
