class CustomException < Exception
  attr_accessor :data
  attr_accessor :status
  def initialize(data, status)
    @data = data
    @status = status
  end
end

class JiraController < ApplicationController
  protect_from_forgery :except => [:createIssue,:saveInfo]
  skip_before_filter :verify_authenticity_token, :if => Proc.new { |c| c.request.format == 'application/json' }

  def performRequest (data)
    require 'net/http'
    require 'timeout'
    require 'logger'

#    raise CustomException.new("timeout")

    url = URI.parse(FiLabInfographics.jira + "/rest/api/2/issue/")
    http = Net::HTTP.new(url.host, url.port)
    http.open_timeout = 15#FiLabInfographics.timeout
    http.read_timeout = 15#FiLabInfographics.timeout
    
    
    req = Net::HTTP::Post.new(url.request_uri)
    req.body = data.to_json
    req.initialize_http_header({"Content-Type" => "application/json"})
    req.basic_auth(FiLabInfographics.jira_username, FiLabInfographics.jira_password)
    
    begin
      res = http.request(req)
    rescue Exception => e
        case e
          when Timeout::Error
            raise CustomException.new("timeout", nil)
          when Errno::ECONNREFUSED
            raise CustomException.new("connection refused", nil)
          when Errno::ECONNRESET
            raise CustomException.new("connection reset", nil)
          when Errno::EHOSTUNREACH
            raise CustomException.new("host not reachable", nil)
          else
            raise CustomException.new("error: #{e.to_s}", nil)
        end
    end
# Logger.info('request');

#    res = Net::HTTP.start(url.host, url.port) { |http| 
#      http.request(req) 
#    } 
  
#     begin
#       res = Net::HTTP.start(url.host, url.port) {|http|
#       http.request(req)
#       }
#     rescue Net::OpenTimeout => e
# 	puts "-----------------"+e.message+"------------------------"
# 	raise e.message
#     end
#   Logger.error(data);   
    
    data = res.body  
    Rails.logger.info(data);
    begin
      result = JSON.parse(data)
    rescue Exception => e
      raise CustomException.new("Error parsing Data", nil)
    end
       
    return result


 
    
#     return result ["queryContextResponse"] ["contextResponseList"]
    
  end
  
  def performRequestWithAttachment (issueKey, attachment)
    require 'rest_client'

    url = URI.parse(FiLabInfographics.jira + "/rest/api/2/issue/"+issueKey+"/attachments")
    
   
    
#     Rails.logger.info("IL FILE SI TROVA QUI: "+attachment);
    
    type = MIME::Types.type_for("trivial.png").first.content_type
   
    Rails.logger.info("TYPE> "+type)
#     Rails.logger.info("FILE> "+type)
#     resource = RestClient::Resource.new(FiLabInfographics.jira, :user => FiLabInfographics.jira_username, :password => FiLabInfographics.jira_password, :headers => {"X-Atlassian-Token" => "nocheck"})
#     result = resource["rest/api/2/issue/"+issueKey+"/attachments"].post File.new(attachment, 'rb')#, :content_type => type
    
    
    request = RestClient::Request.new(
	:method => :post,
	:url => FiLabInfographics.jira + "/rest/api/2/issue/"+issueKey+"/attachments",
	:user => FiLabInfographics.jira_username,
	:password => FiLabInfographics.jira_password,
	:timeout => 30,
	:open_timeout => 30,
	:headers => {"X-Atlassian-Token" => "nocheck"},
	:payload => {
	  :multipart => true,
	  :file => File.new(attachment, 'rb')
	}) 
    
    begin
      result = request.execute
    rescue Exception => e
        case e
          when Timeout::Error
            raise CustomException.new("timeout", nil)
          when Errno::ECONNREFUSED
            raise CustomException.new("connection refused", nil)
          when Errno::ECONNRESET
            raise CustomException.new("connection reset", nil)
          when Errno::EHOSTUNREACH
            raise CustomException.new("host not reachable", nil)
          else
            raise CustomException.new("error: #{e.to_s}", nil)
        end
    end
    
#     resource = RestClient::Resource.new(@url, @username, @password)
#     result = resource.post(FiLabInfographics.jira + "/rest/api/2/issue/"+issueKey+"/attachments", :file => File.new(attachment))
    
    
#     http = Net::HTTP.new(url.host, url.port)
#     http.open_timeout = FiLabInfographics.timeout
#     http.read_timeout = FiLabInfographics.timeout
#     
#     
#     #prepare the query
#     data, headers = Multipart::Post.prepare_query("document" => attachment)
#     
#     
#     
#     
# #     req = Net::HTTP::Post.new(url.request_uri)
# #     req.body = data.to_json
# #     req.initialize_http_header({"X-Atlassian-Token" => "nocheck"})
#     req.basic_auth(FiLabInfographics.jira_username, FiLabInfographics.jira_password)
    
    
#     res = Net::HTTP.start(url.host, url.port) {|http|
#         http.open_timeout = FiLabInfographics.timeout
# 	http.read_timeout = FiLabInfographics.timeout	
# 	
# 	#prepare the query
# 	data, headers = Multipart::Post.prepare_query("file" => attachment)	
# 	
#         req = Net::HTTP::Post.new(url.request_uri, initheader = headers)
#         req.body = data
# 	req.basic_auth(FiLabInfographics.jira_username, FiLabInfographics.jira_password)
# 	
#         begin
# 	  http.request(req)
# 	rescue Exception => e
# 	    case e
# 	      when Timeout::Error
# 		raise CustomException.new("timeout")
# 	      when Errno::ECONNREFUSED
# 		raise CustomException.new("connection refused")
# 	      when Errno::ECONNRESET
# 		raise CustomException.new("connection reset")
# 	      when Errno::EHOSTUNREACH
# 		raise CustomException.new("host not reachable")
# 	      else
# 		raise CustomException.new("error: #{e.to_s}")
# 	    end
# 	end
#       }
#     
#     data = res.body  
#     Rails.logger.info(data);
#     begin
#       result = JSON.parse(data)
#     rescue Exception => e
#       raise CustomException.new("Error parsing Data")
#     end
       
    return result
      
#       res = http.start {|con| con.post(upload_uri.path, data, headers) }
    
    
    
#     begin
#       res = http.request(req)
#     rescue Exception => e
#         case e
#           when Timeout::Error
#             raise CustomException.new("timeout")
#           when Errno::ECONNREFUSED
#             raise CustomException.new("connection refused")
#           when Errno::ECONNRESET
#             raise CustomException.new("connection reset")
#           when Errno::EHOSTUNREACH
#             raise CustomException.new("host not reachable")
#           else
#             raise CustomException.new("error: #{e.to_s}")
#         end
#     end
# Logger.info('request');

#    res = Net::HTTP.start(url.host, url.port) { |http| 
#      http.request(req) 
#    } 
  
#     begin
#       res = Net::HTTP.start(url.host, url.port) {|http|
#       http.request(req)
#       }
#     rescue Net::OpenTimeout => e
# 	puts "-----------------"+e.message+"------------------------"
# 	raise e.message
#     end
#   Logger.error(data);   
    
#     data = res.body  
#     Rails.logger.info(data);
#     begin
#       result = JSON.parse(data)
#     rescue Exception => e
#       raise CustomException.new("Error parsing Data")
#     end
#        
#     return result


 
    
#     return result ["queryContextResponse"] ["contextResponseList"]
    
  end
  
  def createIssue
    require 'tempfile'
#     params read
#     'region_id','environmentId','priority','summary','description','name','email'
#     Rails.logger.info("THE REGION ID: "+params[:region_id]);
    file=nil
 
    if !params[:file_attach].nil? && params[:file_attach]!="undefined"
      file = params[:file_attach]
      filePath = Rails.root.join('tmp', file.original_filename)
      File.open(filePath, 'wb') do |f|      
        f.write(file.read)      
      end
    end
#     fileTmp=Base64.strict_encode64(File.read(Rails.root.join('tmp', file.original_filename)) )
#     fileTmp = File.read(Rails.root.join('tmp', file.original_filename)) 
    
#     File.open(Rails.root.join('tmp', file.original_filename), 'rb') do |f|
#       fileTmp = f.read()
#     end

    
#     file = Tempfile.new(params[:file_attach].tempfile.path);
#     begin
#         Rails.logger.info(file.path);
#     ensure
#         file.close
# #         file.unlink   # deletes the temp file
#     end
    
    jira_project_id = FiLabInfographics.jira_default_project
    environment_id = Hash.new
    environment_id["id"] = params[:environment_id]#FI-Lab or Test-bed
#    issueType = "1"    

    if(params[:environment_id] == "10100")#FI-Lab
      jira_project_id = "XIFI"#test_project
      if(FiLabInfographics.jira_test == 0 && params[:region_id] != "none")
      
  #       ---------------------------------------------
  #       to set jira_project_id dinamically
  #       ---------------------------------------------
	dbNode = Node.where(:rid => params[:region_id]).first
	if dbNode != nil
	  jira_project_id = dbNode.jira_project_id;
#	  issueType = "5"
	end
      elsif (FiLabInfographics.jira_test == 0 && params[:region_id] == "none")
	jira_project_id = FiLabInfographics.jira_default_project
      end
    end 

    if params[:environment_id] == "10101"#Test-bed
	jira_project_id = "XIFI"#test_project
      	if(FiLabInfographics.jira_test == 0)
		jira_project_id = "TBS"
	end
    end     
      
    inputIssueData = Hash.new
    fields = Hash.new
    project_key = Hash.new
    project_key["key"] = jira_project_id #or id=10700
    parent_key = Hash.new
    parent_key["id"] = "10301" #or id=10700
    issuetype_id = Hash.new
    issuetype_id["id"] = "1"#issueType#1 is Bug,2 New Feature,3 is Task,4 Improvement,5 Sub-task,6 Epic,7 Story, 8 Technical task
    prioritytype_id = Hash.new
    prioritytype_id["id"] = params[:priority]#1 is Blocker,2 Critical,3 Major,4 Minor,5 Trivial
    fields["project"] = project_key
    #if issueType == "5"
     #fields["parent"] = parent_key
    #end
    fields["summary"] = params[:summary]
    fields["description"] = params[:description]
    fields["issuetype"] = issuetype_id
    fields["priority"] = prioritytype_id
    fields["customfield_10108"] = environment_id
    fields["customfield_10302"] = params[:name]
    fields["customfield_10301"] = params[:email]
    inputIssueData["fields"] = fields
    
#    Rails.logger.info("\nThe issue:\n"+inputIssueData);
    Rails.logger.info("\n---------------\nTHE JIRA PROJECT: "+jira_project_id+"\n--------------\n");
    
    begin
      outputIssueData = self.performRequest(inputIssueData)
      if(outputIssueData != nil && file != nil)
	begin
	outputAttachmentData = self.performRequestWithAttachment(outputIssueData["key"],filePath)
	Rails.logger.info(outputAttachmentData);
	File.delete(filePath)
	rescue CustomException => e
	  File.delete(filePath)
	  errors = Hash.new
	  errors["errors"] = "Issue created without attachment"
	  render :json=>errors, :status => :service_unavailable
	  return
	end
      end
      render :json => outputIssueData.to_json
    rescue CustomException => e
      errors = Hash.new
      errors["errors"] = e.data
      render :json=>errors, :status => :service_unavailable
    end
    
    
  end
  
  def getInfo
    idNode = params[:idNode]
    if idNode != nil
      dbNode = Node.where(:rid => idNode).first
      if dbNode == nil
	render :json=>"Node not found in db: "+idNode, :status => :service_unavailable
      else 
	response = Hash.new
	response["url"]= dbNode.jira_project_url
	response["id"]= dbNode.jira_project_id
	render :json => response.to_json
      end     
    else render :json=>"Node id not set", :status => :service_unavailable
    end
  end
  
  def saveInfo
    idNode = params[:idNode]
    jiraId = params[:jiraId]
    jiraUrl = params[:jiraUrl]
    Rails.logger.info(idNode+"-"+jiraId+"-"+jiraUrl);
    if idNode != nil
      dbNode = Node.where(:rid => idNode).first
      
      if dbNode == nil
	render :json=>"Node not found in db: "+idNode, :status => :service_unavailable
      else 
	dbNode.jira_project_id = jiraId
	dbNode.jira_project_url = jiraUrl
	dbNode.save
	
	response = Hash.new
	response["status"] = "Node set"
	render :json=>response, :status => 200
      end
    else 
      response = Hash.new
      response["status"] = "Node id not set"
      render :json=>response, :status => :service_unavailable
    end
  end
  
end
