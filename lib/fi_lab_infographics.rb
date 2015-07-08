module FiLabInfographics
  mattr_accessor :nodejs
  mattr_accessor :timeout
  mattr_accessor :nodata
  mattr_accessor :jira
  mattr_accessor :jira_username
  mattr_accessor :jira_password
  mattr_accessor :jira_test
  mattr_accessor :jira_success_message
  mattr_accessor :jira_default_project
#  @@nodejs = 'http://192.168.1.100:80' 
#  @@nodejs = 'http://193.205.211.69:1026'
#  @@nodejs = 'http://127.0.0.1:1336'
#  @@nodejs ='http://130.206.84.4:1028' 
  @@nodejs ='http://130.206.84.4:11027'


  @@timeout = 5
  @@nodata = 'No Data'
  @@jira = 'http://jira.fi-ware.org'
  @@jira_username = 'jira_username'
  @@jira_password = 'jira_password'
  @@jira_test = 1
  @@jira_default_project = 'FIL'
  @@jira_success_message = 'Thanks for reporting your issue. You will receive a notification for every update to the issue.'

  class << self
    def setup
      yield self
    end
  end
end
