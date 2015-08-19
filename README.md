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

### New features available

- Added historical node data visualization.
- Info about Basic Users, Trial Users and Community Users inserted inside main dashboard.

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

Copyright 2015 Create-net.org
All Rights Reserved.
