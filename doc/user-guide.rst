User Guide
==========

Infographics Page
----------

The following figure shows the main page of the Infographics tool. 

.. image:: _static/info.jpg
   :alt: Infographics

It is composed of:

- a big map that shows all nodes;
- seven interactive tabs that display different data;
- the list of FIWARE Lab Capacity supporters;

The user can click on each tab in order to display more details on the map.
Here a short description about each tab:

- Users: it is the total number of users. It is the sum of Basic Users, Trial Users and Community Users;
- Regions, Organizations, Institutions: it is the total number of nodes, organizations and institutions;
- CPU (Cores): it is the total number of physical cores. When this tab is selected, hovering the mouse on a node of the map the number of virtual and physical cores is shown. Moreover the amount of available cores is displayed;
- RAM (GB): it is the total size of physical RAM. When this tab is selected, hovering the mouse on a node of the map the size of virtual and physical RAM is shown. Moreover the amount of available RAM is displayed;
- Disk (TB): it is the total size of disk.  When this tab is selected, hovering the mouse on a node of the map the disk size available/total is shown;
- Public IPs: it is the total number of public IPs. When this tab is selected, hovering the mouse on a node of the map the number available public IPs/total public IPs is shown;
- VM: it is the total number of VMs. When this tab is selected, hovering the mouse on a node of the map the number of VMs is shown.

When data about a specific node are obsolete, the node in the map is greyed and the user can check the timestamp of its last update by passing the cursor over it.

Status Page
----------

.. image:: _static/status.jpg
   :alt: Status Page
   
The Status page is composed by:

- a big map that shows all nodes and their overall status (green, yellow or red);
- a table with all FIWARE Lab nodes services status;
- an histogram that shows the average on the last selected months of the sanity check status for each node.

By clicking on a specific node in the map, the user can check FIWARE services status for a given node and a calendar graph that shows its sanity check status of the last selected months.

.. image:: _static/status2.jpg
   :alt: Status of a given node
   
Node Page
----------

By clicking on a specific node in the map in the Main Page or by clicking on the nodes' names inside table in the Status Page, all data about the specific node are displayed.

.. image:: _static/node.jpg
   :alt: Node Page
   
The Node page is composed by:

- a map that shows node location and its overall status (green, yellow or red);
- CPU, RAM and Disk and their used percentage;
- a table with all services status;
- a table with all computing hosts;
- the list of node supporters;
