User Guide
==========

Main Page
----------

The following figure shows the main page of the Infographics tool. 

.. image:: _static/info.jpg
   :alt: Infographics

It is composed by:
1. a big map that shows all nodes;
2. seven interactive tabs that display different data;
3. the list of FIWARE Lab Capacity supporters;

The user can click on each tab in order to display more details on the map.
Here a short description about each tab:
1. Users: is the total number of users. It is the sum of Basic Users, Trial Users and Community;
2. Regions, Organizations, Institutions: is the total number of nodes, organizations and institutions;
3. CPU (Cores): is the total number of physical cores. When the tab is selected, the
map shows virtual and physical cores for each node. Moreover the amount of available
cores is displayed;
4. RAM (GB): is the total number of physical ram. When the tab is selected, the
map shows virtual and physical ram for each node. Moreover the amount of available RAM is
displayed;
5. Disk (TB): is the total number of disk. When the tab is selected, the
map shows available disk/total disk for each node. Moreover the amount of available Disk is
displayed;
6. Public IPs: is the total number of public IPs. When the tab is selected, the
map shows available public IPs/total public IPs for each node;
7. VM: is the total number of VMs. When the tab is selected, the
map shows the number of VMs for each node;

When data about a specific node are obsolete, the node in the map is grey and the user can check
time of its last update by passing the cursor over it.

Status Page
----------

.. image:: _static/status.jpg
   :alt: Status Page
   
The Status page is composed by:
1. a big map that shows all nodes and their overall status (green, yellow or red);
2. a table with all FIWARE Lab nodes services status;
3. an histogram that shows the average on the last selected months of the sanity check status for
each node.

By clicking on a specific node in the map, the user can check FIWARE services status for a given node
and a calendar graph that shows its sanity check status of the last selected months.

.. image:: _static/status2.jpg
   :alt: Status of a given node
   
Node Page
----------

By clicking on a specific node in the map in the Main Page or by clicking on the nodes' names inside table in the Status Page, all data about the specific node are displayed.

.. image:: _static/node.jpg
   :alt: Node Page
   
The Node page is composed by:
1. a map that shows node location and its overall status (green, yellow or red);
2. CPU, RAM and Disk and their used percentage;
3. a table with all services status;
4. a table with all computing hosts;
5. the list of node supporters;