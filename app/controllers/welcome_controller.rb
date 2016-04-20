class WelcomeController < FiLabApp::ApplicationController
 include FiLabApp::UserHelper
 #before_filter :authenticate_user!

  class CustomException < Exception
    attr_accessor :data
    attr_accessor :status
    def initialize(data, status)
      @data = data
      @status = status
    end
  end

  #perform request to federation monitoring API.
  def performRequest (uri)
    require 'net/http'
    require 'timeout'
    require 'logger'
    require 'open-uri'
    
    uri = uri.force_encoding('ASCII-8BIT')
    uri = URI::encode(uri)


    url = URI.parse(FiLabInfographics.nodejs + "/monitoring/" + uri)

    http = Net::HTTP.new(url.host, url.port)
    http.open_timeout = FiLabInfographics.timeout
    http.read_timeout = FiLabInfographics.timeout
    
    req = Net::HTTP::Get.new(url.request_uri)
    req.initialize_http_header({"Accept" => "application/json"})
   
    begin
      
      res = http.start do |http|
        http.request(req)
      end
#       res = http.request(req)
    rescue StandardError, Timeout::Error => e
      case e
	when Timeout::Error
	  raise CustomException.new("timeout",nil)
	  return
	when Errno::ECONNREFUSED
	  raise CustomException.new("connection refused",nil)
	  return
	when Errno::ECONNRESET
	  raise CustomException.new("connection reset",nil)
	  return
	when Errno::EHOSTUNREACH
	  raise CustomException.new("host not reachable",nil)
	  return
	else
	  raise CustomException.new("error: #{e.to_s}",nil)
	  return
      end
    end
    
#     if res.code == 503
#       raise CustomException.new(res.body)
#       return
#     end
    if res.code == "404"
      Rails.logger.info("THE HTTP STATUS: "+res.code);
      raise CustomException.new("Not Found", res.code)
      return
    elsif res.code == "401"
      Rails.logger.info("THE HTTP STATUS: "+res.code);
      raise CustomException.new("Unauthorized", res.code)
      return
    elsif res.code == "500"
      Rails.logger.info("THE HTTP STATUS: "+res.code);
      raise CustomException.new("Internal Server Error", res.code)
      return
    elsif res.code == "502"
      Rails.logger.info("THE HTTP STATUS: "+res.code);
      raise CustomException.new("Bad Gateway", res.code)
      return
    elsif res.code == "503"
      Rails.logger.info("THE HTTP STATUS: "+res.code);
      raise CustomException.new("Service Unavailable", res.code)
      return    
    end
    
    data = res.body   
    
    begin
      result = JSON.parse(data)      
    rescue Exception => e

      raise CustomException.new(data, nil)
    end

    return result

  end
  
  #get specific data about one region
  def getRegionsDataForNodeId (idNode)
    begin
      regionsData = self.performRequest('regions/' + idNode)
    rescue CustomException => e
      raise e
    end

    if regionsData != nil
            
      attributesRegion = Hash.new
      attributesRegion["id"] = regionsData["id"]
      if(regionsData["id"]=='Berlin2')
         attributesRegion["name"] = 'Berlin'
      elsif(regionsData["id"]=='Spain2')
         attributesRegion["name"] = 'Spain'
      elsif(regionsData["id"]=='Lannion2')
         attributesRegion["name"] = 'Lannion'
      elsif(regionsData["id"]=='Karlskrona2')
         attributesRegion["name"] = 'Karlskrona'
      elsif(regionsData["id"]=='Budapest2')
         attributesRegion["name"] = 'Budapest'
      elsif(regionsData["id"]=='Stockholm2')
         attributesRegion["name"] = 'Stockholm'
      else 
        attributesRegion["name"] = regionsData["name"]
      end

      attributesRegion["country"] = regionsData["country"]
      attributesRegion["latitude"] = regionsData["latitude"]
      attributesRegion["longitude"] = regionsData["longitude"]
      
      if regionsData["measures"]!= nil && regionsData["measures"].length > 0 && regionsData["measures"][0]!= nil
	
	attributesRegion["timestamp"] = regionsData["measures"][0]["timestamp"]
	attributesRegion["nb_users"] = regionsData["measures"][0]["nb_users"]
	attributesRegion["nb_cores"] = regionsData["measures"][0]["nb_cores"]
	attributesRegion["nb_cores_used"] = regionsData["measures"][0]["nb_cores_used"]
	attributesRegion["nb_ram"] = regionsData["measures"][0]["nb_ram"]
	attributesRegion["percRAMUsed"] = regionsData["measures"][0]["percRAMUsed"]
	if(regionsData["measures"][0]["cpu_allocation_ratio"])
	  attributesRegion["cpu_allocation_ratio"] = regionsData["measures"][0]["cpu_allocation_ratio"]
	else
	  attributesRegion["cpu_allocation_ratio"] = 16.0
	end
	if(regionsData["measures"][0]["ram_allocation_ratio"])
	  attributesRegion["ram_allocation_ratio"] = regionsData["measures"][0]["ram_allocation_ratio"]
	else
	  attributesRegion["ram_allocation_ratio"] = 1.5
	end
	attributesRegion["nb_disk"] = regionsData["measures"][0]["nb_disk"]
	attributesRegion["percDiskUsed"] = regionsData["measures"][0]["percDiskUsed"]
	attributesRegion["ipTot"] = regionsData["measures"][0]["ipTot"]
	attributesRegion["ipAllocated"] = regionsData["measures"][0]["ipAllocated"]
	attributesRegion["ipAssigned"] = regionsData["measures"][0]["ipAssigned"]
	attributesRegion["nb_vm"] = regionsData["nb_vm"]
	
      end

      return attributesRegion

    end 
    return nil
  end
  
  def info
  end

  def status
  end

  def historical
  end

  def node 
    @idNode = params[:nodeId]
    @nameNode = ""
    @categoryNode = nil
    @theNode = []
    
    if @idNode != nil
      begin
	nodeData = self.getRegionsDataForNodeId (@idNode)
	if(nodeData != nil)
	  @nameNode = nodeData["name"]
	  @theNode = nodeData.to_json
	  dbNode = Node.where(:rid => @idNode).first
	  if dbNode != nil
	   @categoryNode = dbNode.category
	  end
	end
      rescue CustomException => e
	@idNode = nil
      end
    end    
  end
  
  def history 
    @idNode = params[:nodeId]
    @nameNode = ""
    @categoryNode = ""
    
    if @idNode != nil
      dbNode = Node.where(:rid => @idNode).first
      if dbNode == nil
	@idNode = nil
      else 
	@nameNode = dbNode.name
	@categoryNode = dbNode.category
      end
    end    
  end
  
  def mynode 
    @idUser = params[:id]
    @idNode = nil
    @nameNode = nil
    
    if @idUser != nil
      dbUser = FiLabApp::User.where(:id => @idUser).first
      if dbUser == nil
	@idUser = nil
      elsif dbUser.node
	@idNode = dbUser.node.rid
	@nameNode = dbUser.node.name
      end
    end    
  end
  
  def ownerinstitutions 
    @idUser = params[:id]
    @idNode = nil
    @nameNode = nil
    
    if @idUser != nil
      dbUser = FiLabApp::User.where(:id => @idUser).first
      if dbUser == nil
	@idUser = nil
      elsif dbUser.node
	@idNode = dbUser.node.rid
	@nameNode = dbUser.node.name
      end
    end    
  end
  
  def admin 
    @idUser = params[:id]  
    if @idUser != nil
      dbUser = FiLabApp::User.where(:id => @idUser).first
      if dbUser == nil
	@idUser = nil
      end
    end
  end
  
  def admininstitutions 
    @idUser = params[:id]  
    if @idUser != nil
      dbUser = FiLabApp::User.where(:id => @idUser).first
      if dbUser == nil
	@idUser = nil
      end
    end    
  end
  
end
