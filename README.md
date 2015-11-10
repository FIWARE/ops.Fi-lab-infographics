# FI-Lab Infographics

This is the code repository for the FI-Lab Infographics, a Ruby on Rails Application that provides a view of FI-Lab nodes capacities and status via an infographic style. This project is part of FI-Core.

## Overall description

FI-Lab Infographics is a simple but important service to allow users to:

- know in a intuitive way about the infrastructure capacities made available by FI-Lab infrastructure;
- monitor current status of infrastructure services and know about any issue in any node of FI-Lab infrastructure.

While the information on infrastructure capacities is more related to marketing, the one of serivces status is extremely important to support Developers and Federation Managers operations. To our best knowledge there is not such service available as opensource for OpenStack related infrastructures, thus this required a new development. 

Real demo here:  
PROD  
http://infographic.lab.fi-ware.org/  
http://status.lab.fi-ware.org/  
DEV  
http://infographic.lab.fi-ware.eu/  
http://status.lab.fi-ware.eu/

The component retrieves existing infrastructure services and regions from the Federation Manager. This component provide as well the status information of infrastructure services. The IdM GE provides authentication mechanism to support message posting by the Federation Manager and the Infrastructure Owners. The Federation Monitor component provides data on the capacity and status of FI-Lab infrastructure. 

![FI-Lab Infographics Architecture](http://wiki.fi-xifi.eu/wiki/images/b/b8/Infographics-arch1.0.png)

### Release History

- 23/06/2015 Added historical node data visualization.
- 14/08/2015 Added information on the number of different types of users (trial, basic and community).
- 9/11/2015: 
  - Layout changes (in particular in the presentation of the map and of the detailed information on RAM, CPU, DISK, IP etc.)
  - Added list of institutions supporting the FIWARE Lab
  - Integration of the sanity check results into the Status Page: now for each node the current sanity check status is provided. Moreover an historical view of the sanity check status is provided (average of the values collected from the month specified in the calendar tab) based on an histogram
  - added information on the historical values of the sanity check for a given node for each day: in the Status Page clicking on a node in the map you will be redirected to a page where the sanity check historical data is presented in a sort of "calendar per day"
  -added information on the resources of a single node: clicking on a node in the table "FIWARE Service Status" of Status Page, a page showing the detail of that node is presented. Here you can find info about the resources of that node and of its status.

## Installation

### Prerequisites

Ubuntu 12.04 as operating system.
Ruby on Rails v2.0.0-p247 installed.

### Setup Guide

Once Ruby on Rails is installed, dowload the code:

```
git clone -b develop https://github.com/SmartInfrastructures/fi-lab-infographics.git
```

Build the application:

```
ubuntu@ubuntu:~$ cd fi-lab-infographics
ubuntu@ubuntu:~/filab-style-app$ bundle install
```

Configure the end point of the federation monitor in config/initializers/0infographics.rb: 

```
require_dependency 'fi_lab_infographics'

FiLabInfographics.setup do |config|
  # Node.js proxy for monitoring
  config.nodejs = 'http://monitoring.fi-xifi.eu:1339'

end
```

Configure the connection with the database in config/database.yml: 

```
# MySQL (default setup).  Versions 4.1 and 5.0 are recommended.
#
development:
  adapter: mysql2
  database: infographics_development
  encoding: utf8
  username: userWithRootPrivileges
  password: thePassword
  socket: /var/run/mysqld/mysqld.sock
```

Create the database infographics_development. In order to create and populate tables, run: 

```
rake fi_lab_app:install:migrations
rake db:migrate
rake db:seed
```

Launch the application:

```
rails server
```

### User manual
In order to use the Infographics tool, please refer to [user guide](doc/user-guide.rst)

Copyright 2015 Create-net.org
All Rights Reserved.
