require 'oauth2'
require 'time'
 
class CustomException < Exception
  attr_accessor :data
  attr_accessor :status
  def initialize(data, status)
    @data = data
    @status = status
  end
end

class RegionController < ApplicationController
#   protect_from_forgery except: :renderInstitutions
  skip_before_filter :verify_authenticity_token, :if => Proc.new { |c| c.request.format == 'application/json' }
  
  @@token = nil

  def self.getToken
    if @@token && @@token.expired?
      begin

        basic_auth_header="Basic " + Base64.strict_encode64(FiLabInfographics.client_id+":"+FiLabInfographics.client_secret)
# 	oauth2._customHeaders={Authorization: 'Basic '+new Buffer(ConsumerKey+":"+ConsumerSecret).toString('base64')}

        client = OAuth2::Client.new(FiLabInfographics.client_id, FiLabInfographics.client_secret,
          :site => FiLabApp.account_server, :authorize_url => FiLabApp.account_server + '/oauth2/authorize', :token_url => FiLabApp.account_server + '/oauth2/token')

        #token = client.client_credentials.get_token

        #token = client.password.get_token('***REMOVED***', '***REMOVED***', :headers => {'Authorization' => basic_auth_header })
        token = client.password.get_token( FiLabInfographics.jira_username, FiLabInfographics.jira_password, :headers => {'Authorization' => basic_auth_header })
        RegionController.setToken(token)
      rescue Exception => e
        logger.error e
      end
      logger.debug "new token: " + @@token.token
    end
    return @@token
  end
  
  def self.setToken(token)
    if token
      logger.info "setting token: " + token.token
    end
    @@token=token
  end

  def initialize
    super # this calls ActionController::Base initialize
    
    if @@token==nil
      begin
  
        basic_auth_header="Basic " + Base64.strict_encode64(FiLabInfographics.client_id+":"+FiLabInfographics.client_secret)
        

        client = OAuth2::Client.new(FiLabInfographics.client_id, FiLabInfographics.client_secret,
          :site => FiLabApp.account_server, :authorize_url => FiLabApp.account_server + '/oauth2/authorize', :token_url => FiLabApp.account_server + '/oauth2/token')

        #token = client.client_credentials.get_token
        #token = client.password.get_token('***REMOVED***', '***REMOVED***', :headers => {'Authorization' => basic_auth_header })
        token = client.password.get_token( FiLabInfographics.jira_username, FiLabInfographics.jira_password, :headers => {'Authorization' => basic_auth_header })
        RegionController.setToken(token)
      rescue Exception => e
        logger.debug 'error while getting token: ' + e.to_s
      end
    end
  end
  
  #perform request to federation monitoring API. If secure is true, then oauth token is set in request
  def performRequest (uri, secure)
    require 'net/http'
    require 'timeout'
    require 'logger'
    require 'open-uri'
    
    if RegionController.getToken==nil
       raise CustomException.new("IDM service unavailable", nil)
       return
    end
    
    uri = uri.force_encoding('ASCII-8BIT')
    uri = URI::encode(uri)


    if secure
      url = URI.parse(FiLabInfographics.securenodejs + "/monitoring/" + uri)
    else
      url = URI.parse(FiLabInfographics.nodejs + "/monitoring/" + uri)
    end
    http = Net::HTTP.new(url.host, url.port)
    http.open_timeout = FiLabInfographics.timeout
    http.read_timeout = FiLabInfographics.timeout
    
    req = Net::HTTP::Get.new(url.request_uri)
    req.initialize_http_header({"Accept" => "application/json"})
    
    
    oauthToken = Base64.strict_encode64( RegionController.getToken.token )
#    //UNCOMMENT IN ORDER TO USE OAUTH
    if secure
      req.add_field("Authorization", "Bearer "+oauthToken)
    end
#    Rails.logger.debug(req.get_fields('Authorization'));
#    Rails.logger.debug(req.get_fields('Accept'));
#    Rails.logger.debug(url.request_uri);
    
#    startTime=Time.now.to_i
    
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
#       Rails.logger.info("\nTHE HTTP STATUS: "+res.code+"\nTHE DATA RESPONSE: "+data+"\n--------------\n")
#       raise CustomException.new("Error parsing Data", nil)
      raise CustomException.new(data, nil)
    end
#     endTime=Time.now.to_i
# 
#     delta=endTime-startTime
#     Rails.logger.info("duration: ");
#     Rails.logger.info(delta)
#       
#     Rails.logger.info("JSON RETURNED:"+result.to_s)
    return result

  end
  
  #check and shift two map points too close 
  def checkLatLong (points)
    
    if(points['PiraeusN'] != nil && points['PiraeusN']["latitude"] != nil)
      points['PiraeusN']["latitude"] = points['PiraeusN']["latitude"].to_f+0.5
      points['PiraeusN']["longitude"] = points['PiraeusN']["longitude"].to_f-1
    end
      
#     points.each do |regionToCheckKey,regionToCheck|
#       points.each do |regionKey,region|
# 	if regionToCheck["id"] != region["id"]
# 	  if (regionToCheck["latitude"].to_f - region["latitude"].to_f).abs < 0.2
# 	    regionToCheck["latitude"] = regionToCheck["latitude"].to_f+0.5
# 	  end
# 	  if (regionToCheck["longitude"].to_f - region["longitude"].to_f).abs < 0.2
# 	    regionToCheck["longitude"] = regionToCheck["longitude"].to_f+0.5
# 	  end
# 	end
#       end
#     end
    
    return points
  end
  
  #get all general data and specific data about all regions 
  def getRegionsData (histogramData)
    
    begin
      totRegionsData = self.getRegionsTotData
    rescue CustomException => e
      raise e
      return
    end
    
    if totRegionsData != nil
      
      idRegions = totRegionsData["total_regions_ids"]
    
      attributes = Hash.new
    
      idRegions.each do |idRegion|
	begin
	  if (histogramData != nil)
	    attributesRegion = self.getRegionsDataForNodeId(idRegion)
	  else
	    attributesRegion = self.getRegionsDataForNodeIdWithoutHistogramData(idRegion)
	  end
	rescue CustomException => e
	  raise e
	  return
	end
	
	attributes[idRegion] = attributesRegion
	
      end    
      
      attributes = checkLatLong (attributes);
      returnData = Hash.new
      returnData ["regions"] = attributes;
      returnData ["tot"] = totRegionsData;
      
      return returnData;
      
    end
    return nil
  end
  
  #render all general data and specific data about all regions 
  def renderRegions
    histogramData = params[:histogramData]
    begin
      regionsData = self.getRegionsData(histogramData)
    rescue CustomException => e
      if e.status
	render :json=>"Problem in retrieving data for all nodes: "+e.data, :status => e.status
      else
	render :json=>"Problem in retrieving data for all nodes: "+e.data, :status => :service_unavailable
      end
      return
    end
    
    
    if regionsData == nil
      render :json=>"Problem in retrieving data: no data", :status => :service_unavailable
      return
    end
    render :json => regionsData.to_json
  end
  
  #render all general data about regions 
  def renderRegionsTotData
    begin
      totRegionsData = self.getRegionsTotData
    rescue CustomException => e
      if e.status
	render :json=>"Problem in retrieving tot data for all regions : "+e.data, :status => e.status
      else
	render :json=>"Problem in retrieving tot data for all regions : "+e.data, :status => :service_unavailable
      end
      return
    end  
      
    render :json => totRegionsData.to_json
  end
  
  #get all general data about regions 
  def getRegionsTotData
    begin
      regionsData = self.performRequest('regions', false)
    rescue CustomException => e
      raise e
      return
    end
    
    
    if regionsData != nil
      idRegions = [] 
      
      if regionsData["_embedded"] != nil && regionsData["_embedded"]["regions"] != nil
	regionsData["_embedded"]["regions"].each do |region|
                  if (region["id"]!='Berlin' and region["id"]!='Karlskrona' and region["id"]!='Budapest' and region["id"]!='Lannion' and region["id"]!='Spain' and region["id"]!='Stockholm')
		    idRegions.push(region["id"])
                  end 
	end
      else
	raise CustomException.new("No data about regions", nil)
	return
      end
      
      totValues = Hash.new
     
      totValues["basicUsers"]=regionsData["basicUsers"];
      totValues["trialUsers"]=regionsData["trialUsers"];
      totValues["communityUsers"]=regionsData["communityUsers"];
      totValues["total_nb_users"] = regionsData["total_nb_users"];
      totValues["totalUserOrganizations"] = regionsData["totalUserOrganizations"];
      totValues["totalCloudOrganizations"] = regionsData["totalCloudOrganizations"];
      totValues["total_nb_organizations"] = regionsData["total_nb_organizations"];
      totValues["total_nb_cores"] = regionsData["total_nb_cores"];
      totValues["total_nb_ram"] = regionsData["total_nb_ram"];
      totValues["total_nb_disk"] = regionsData["total_nb_disk"];
      totValues["total_nb_vm"] = regionsData["total_nb_vm"];
      totValues["total_ip_allocated"] = regionsData["total_ip_allocated"];
      totValues["total_ip_assigned"] = regionsData["total_ip_assigned"];
      totValues["total_ip"] = regionsData["total_ip"];
      totValues["total_regions_ids"] = idRegions;
      totValues["total_regions_count"] = idRegions.count;
      
      return totValues
      
    end
    return nil
  end
  
  #render specific data about one region
  def renderRegionsDataForRegion
    idNode = params[:nodeId]
    begin
      regionsData = self.getRegionsDataForNodeId(idNode)
    rescue CustomException => e
      if e.status
	render :json=>"Problem in retrieving data for region "+idNode+": "+e.data, :status => e.status
      else
	render :json=>"Problem in retrieving data for region "+idNode+": "+e.data, :status => :service_unavailable
      end
      return
    end
    
    render :json => regionsData.to_json
  end
  
  #get specific data about one region
  def getRegionsDataForNodeId (idNode)
    begin
      regionsData = self.performRequest('regions/' + idNode, false)
      #########################################################################
      #       For this first draft I take an hardcoded startintervall         #
      #########################################################################
      #regionsDataLive= self.performRequest('regions/' + idNode+"/services")
      regionsDataMonthHist = self.performRequest('regions/' + idNode+"/services?since=2015-01-01T00:00&aggregate=m", false)
      regionsDataLive= self.performRequest('regions/' + idNode+"/services", false)
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
      #if (regionsData["id"]=="Berlin2")

      # For testing/demo purposes: data for histogram about historical sanity checks success
      #if ENV["RAILS_ENV"] == "test"
      ####################################################################################
      #                 Here is where I aggregate the info                               #
      ####################################################################################
     
      #logger.info regionsDataMonthHist
      sanityTot    =0
      sanityCounter=0
      attributesRegion["sanityLive"] = STATUS_NA;
      if regionsDataLive !=nil && regionsDataLive["measures"] != nil && regionsDataLive["measures"].length > 0 && regionsDataLive["measures"][0] != nil && regionsDataLive["measures"][0]["FiHealthStatus"] != nil 
         attributesRegion["sanityLive"]=regionsDataLive["measures"][0]["FiHealthStatus"]["value"]
      end
      if regionsDataMonthHist != nil &&  regionsDataMonthHist["measures"] != nil && regionsDataMonthHist["measures"].length > 0
        
	for sample  in regionsDataMonthHist["measures"]

	  if sample["FiHealthStatus"] != nil
	    sampleVal = sample["FiHealthStatus"]["value_clean"];
	    if sample["FiHealthStatus"]["value_clean"] == "undefined"
	      sampleVal=0.0
	    else
	      sanityCounter = sanityCounter + 1;
	    end 
	    sanityTot = sanityTot + sampleVal;
	  end
	end
      
      end

      require 'json'
      if  sanityCounter == 0
        attributesRegion["percSanitySuccess"] = 0.0
      end 
      if sanityCounter != 0
        attributesRegion["percSanitySuccess"] =  1.0 * (sanityTot/sanityCounter)
      end 
      #logger.info attributesRegion["percSanitySuccess"]
      #success = JSON.parse(File.read('test/assets/histogram.json'))[idNode]
      #attributesRegion["percSanitySuccess"] = success
      #logger.info regionsDataMonthHist
      #regionsDataMonthHist
      #end

      return attributesRegion
      #end
    end 
    return nil
  end
  
  #get specific data about one region without Histogram Data
  def getRegionsDataForNodeIdWithoutHistogramData (idNode)
    begin
      regionsData = self.performRequest('regions/' + idNode, false)
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
  
  #render specific data about one region since timestamp
  def renderRegionsDataForRegionSince
    granularity = nil 
    if !params[:granularity].nil? && params[:granularity]!="undefined"
      granularity = params[:granularity]
    end
    idNode = params[:nodeId]
    timestamp = params[:timestamp]
    begin
      regionsData = self.getRegionsDataForNodeIdSince(idNode, timestamp, granularity)
    rescue CustomException => e
      if e.status
	render :json=>"Problem in retrieving data for region "+idNode +" since "+timestamp +": "+e.data, :status => e.status
      else
	render :json=>"Problem in retrieving data for region "+idNode +" since "+timestamp +": "+e.data, :status => :service_unavailable
      end
      return
    end
    
    render :json => regionsData.to_json
  end
  
  #get specific data about one region since timestamp
  def getRegionsDataForNodeIdSince (idNode, timestamp, granularity)
    begin
      regionsData = self.performRequest('regions/' + idNode + "?since=" + timestamp, false)
    rescue CustomException => e
      raise e
    end
    
    if regionsData != nil && regionsData["measures"] != nil
      
      regionMeasures = Hash.new
      regionsData["measures"].each do |measure|
            
	attributesRegion = Hash.new	

	attributesRegion["nb_users"] = measure["nb_users"]
	attributesRegion["nb_cores"] = measure["nb_cores"]
	attributesRegion["nb_cores_used"] = measure["nb_cores_used"]
	attributesRegion["nb_ram"] = measure["nb_ram"]
	attributesRegion["percRAMUsed"] = measure["percRAMUsed"]
	if(measure["cpu_allocation_ratio"])
	  attributesRegion["cpu_allocation_ratio"] = measure["cpu_allocation_ratio"]
	else
	  attributesRegion["cpu_allocation_ratio"] = 16.0
	end
	if(measure["ram_allocation_ratio"])
	  attributesRegion["ram_allocation_ratio"] = measure["ram_allocation_ratio"]
	else
	  attributesRegion["ram_allocation_ratio"] = 1.5
	end
	attributesRegion["nb_disk"] = measure["nb_disk"]
	attributesRegion["percDiskUsed"] = measure["percDiskUsed"]
	attributesRegion["ipTot"] = measure["ipTot"]
	attributesRegion["ipAllocated"] = measure["ipAllocated"]
	attributesRegion["ipAssigned"] = measure["ipAssigned"]
	attributesRegion["nb_vm"] = measure["nb_vm"]
	
	regionMeasures[measure["timestamp"]] = attributesRegion;
      end
#       regionMeasures = Hash[regionMeasures.to_a.reverse]
      if !granularity.nil?
	regionMeasures = groupRegionDataWithGranularity(regionMeasures, granularity)
      end
      return regionMeasures;
    end 
    return nil
  end
  
  def groupRegionDataWithGranularity (regionData, granularity)
    if !granularity.nil?
      if granularity == "day"
	regionMeasures = Hash.new
	regionData.each do |timestamp, data|
# 	  if timestamp of day not in hash --> put in hash and put its attributes in arrays
	  dayTimestamp = timestamp.to_s.sub( %r{T[0-9]{2}:[0-9]{2}:[0-9]{2}.[0-9]{3}Z}, "" ) 
	  if !regionMeasures.include? dayTimestamp
# 	    regionMeasures.push(dayTimestamp)
	    attributesRegion = Hash.new	    
	    attributesRegion["nb_users"] = [data["nb_users"]]
	    attributesRegion["nb_cores"] = [data["nb_cores"]]
	    attributesRegion["nb_cores_used"] = [data["nb_cores_used"]]
	    attributesRegion["nb_ram"] = [data["nb_ram"]]
	    attributesRegion["percRAMUsed"] = [data["percRAMUsed"]]
	    attributesRegion["cpu_allocation_ratio"] = [data["cpu_allocation_ratio"]]
	    attributesRegion["ram_allocation_ratio"] = [data["ram_allocation_ratio"]]
	    attributesRegion["nb_disk"] = [data["nb_disk"]]
	    attributesRegion["percDiskUsed"] = [data["percDiskUsed"]]
	    attributesRegion["ipTot"] = [data["ipTot"]]
	    attributesRegion["ipAllocated"] = [data["ipAllocated"]]
	    attributesRegion["ipAssigned"] = [data["ipAssigned"]]
	    attributesRegion["nb_vm"] = [data["nb_vm"]]
	    regionMeasures[dayTimestamp] = attributesRegion
# 	  if tmestamp of day in hash put its attributes in arrays
	  else
	    regionMeasures[dayTimestamp]["nb_users"].push(data["nb_users"])
	    regionMeasures[dayTimestamp]["nb_cores"].push(data["nb_cores"])
	    regionMeasures[dayTimestamp]["nb_cores_used"].push(data["nb_cores_used"])
	    regionMeasures[dayTimestamp]["nb_ram"].push(data["nb_ram"])
	    regionMeasures[dayTimestamp]["percRAMUsed"].push(data["percRAMUsed"])
	    regionMeasures[dayTimestamp]["cpu_allocation_ratio"].push(data["cpu_allocation_ratio"])
	    regionMeasures[dayTimestamp]["ram_allocation_ratio"].push(data["ram_allocation_ratio"])
	    regionMeasures[dayTimestamp]["nb_disk"].push(data["nb_disk"])
	    regionMeasures[dayTimestamp]["percDiskUsed"].push(data["percDiskUsed"])
	    regionMeasures[dayTimestamp]["ipTot"].push(data["ipTot"])
	    regionMeasures[dayTimestamp]["ipAllocated"].push(data["ipAllocated"])
	    regionMeasures[dayTimestamp]["ipAssigned"].push(data["ipAssigned"])
	    regionMeasures[dayTimestamp]["nb_vm"].push(data["nb_vm"])
	  end	  
	end
# 	Rails.logger.debug(regionMeasures)
# 	new cycle on regionMeasures to compute average
	regionMeasures.each do |timestamp, data|
	  
	  regionMeasures[timestamp]["nb_users"] = computeArrayAverage(regionMeasures[timestamp]["nb_users"])
	  regionMeasures[timestamp]["nb_cores"] = computeArrayAverage(regionMeasures[timestamp]["nb_cores"])
	  regionMeasures[timestamp]["nb_cores_used"] = computeArrayAverage(regionMeasures[timestamp]["nb_cores_used"])
	  regionMeasures[timestamp]["nb_ram"] = computeArrayAverage(regionMeasures[timestamp]["nb_ram"])
	  regionMeasures[timestamp]["percRAMUsed"] = computeArrayAverage(regionMeasures[timestamp]["percRAMUsed"])
	  regionMeasures[timestamp]["cpu_allocation_ratio"] = computeArrayAverage(regionMeasures[timestamp]["cpu_allocation_ratio"])
	  regionMeasures[timestamp]["ram_allocation_ratio"] = computeArrayAverage(regionMeasures[timestamp]["ram_allocation_ratio"])
	  regionMeasures[timestamp]["nb_disk"] = computeArrayAverage(regionMeasures[timestamp]["nb_disk"])
	  regionMeasures[timestamp]["percDiskUsed"] = computeArrayAverage(regionMeasures[timestamp]["percDiskUsed"])
	  regionMeasures[timestamp]["ipTot"] = computeArrayAverage(regionMeasures[timestamp]["ipTot"])
	  regionMeasures[timestamp]["ipAllocated"] = computeArrayAverage(regionMeasures[timestamp]["ipAllocated"])
	  regionMeasures[timestamp]["ipAssigned"] = computeArrayAverage(regionMeasures[timestamp]["ipAssigned"])
	  regionMeasures[timestamp]["nb_vm"] = computeArrayAverage(regionMeasures[timestamp]["nb_vm"])

	end
      elsif granularity == "week"	
	regionMeasures = Hash.new
	regionData.each do |timestamp, data|
# 	  if timestamp of week not in hash --> put in hash and put its attributes in arrays	  
	  weekTimestamp = timestamp.to_s.sub( %r{T[0-9]{2}:[0-9]{2}:[0-9]{2}.[0-9]{3}Z}, "" ) 
# 	  year = timestamp.to_s.sub( %r{-[0-9]{2}-[0-9]{2}T[0-9]{2}:[0-9]{2}:[0-9]{2}.[0-9]{3}Z}, "" )
# 	  date = Date.strptime(weekTimestamp, "%Y-%m-%d")
# 	  weekNumber = date.strftime("%U").to_i # 43
# 	  week = year.to_s+","+weekNumber.to_s+" week"
	  date = Date.strptime(weekTimestamp, "%Y-%m-%d")
	  week = date.beginning_of_week.strftime("%Y-%m-%d")
	  if !regionMeasures.include? week
	    attributesRegion = Hash.new	    
	    attributesRegion["nb_users"] = [data["nb_users"]]
	    attributesRegion["nb_cores"] = [data["nb_cores"]]
	    attributesRegion["nb_cores_used"] = [data["nb_cores_used"]]
	    attributesRegion["nb_ram"] = [data["nb_ram"]]
	    attributesRegion["percRAMUsed"] = [data["percRAMUsed"]]
	    attributesRegion["cpu_allocation_ratio"] = [data["cpu_allocation_ratio"]]
	    attributesRegion["ram_allocation_ratio"] = [data["ram_allocation_ratio"]]
	    attributesRegion["nb_disk"] = [data["nb_disk"]]
	    attributesRegion["percDiskUsed"] = [data["percDiskUsed"]]
	    attributesRegion["ipTot"] = [data["ipTot"]]
	    attributesRegion["ipAllocated"] = [data["ipAllocated"]]
	    attributesRegion["ipAssigned"] = [data["ipAssigned"]]
	    attributesRegion["nb_vm"] = [data["nb_vm"]]
	    regionMeasures[week] = attributesRegion
# 	  if tmestamp of week in hash put its attributes in arrays
	  else
	    regionMeasures[week]["nb_users"].push(data["nb_users"])
	    regionMeasures[week]["nb_cores"].push(data["nb_cores"])
	    regionMeasures[week]["nb_cores_used"].push(data["nb_cores_used"])
	    regionMeasures[week]["nb_ram"].push(data["nb_ram"])
	    regionMeasures[week]["percRAMUsed"].push(data["percRAMUsed"])
	    regionMeasures[week]["cpu_allocation_ratio"].push(data["cpu_allocation_ratio"])
	    regionMeasures[week]["ram_allocation_ratio"].push(data["ram_allocation_ratio"])
	    regionMeasures[week]["nb_disk"].push(data["nb_disk"])
	    regionMeasures[week]["percDiskUsed"].push(data["percDiskUsed"])
	    regionMeasures[week]["ipTot"].push(data["ipTot"])
	    regionMeasures[week]["ipAllocated"].push(data["ipAllocated"])
	    regionMeasures[week]["ipAssigned"].push(data["ipAssigned"])
	    regionMeasures[week]["nb_vm"].push(data["nb_vm"])
	  end	  
	end
# 	Rails.logger.debug(regionMeasures)
# 	new cycle on regionMeasures to compute average
	regionMeasures.each do |timestamp, data|
	  
	  regionMeasures[timestamp]["nb_users"] = computeArrayAverage(regionMeasures[timestamp]["nb_users"])
	  regionMeasures[timestamp]["nb_cores"] = computeArrayAverage(regionMeasures[timestamp]["nb_cores"])
	  regionMeasures[timestamp]["nb_cores_used"] = computeArrayAverage(regionMeasures[timestamp]["nb_cores_used"])
	  regionMeasures[timestamp]["nb_ram"] = computeArrayAverage(regionMeasures[timestamp]["nb_ram"])
	  regionMeasures[timestamp]["percRAMUsed"] = computeArrayAverage(regionMeasures[timestamp]["percRAMUsed"])
	  regionMeasures[timestamp]["cpu_allocation_ratio"] = computeArrayAverage(regionMeasures[timestamp]["cpu_allocation_ratio"])
	  regionMeasures[timestamp]["ram_allocation_ratio"] = computeArrayAverage(regionMeasures[timestamp]["ram_allocation_ratio"])
	  regionMeasures[timestamp]["nb_disk"] = computeArrayAverage(regionMeasures[timestamp]["nb_disk"])
	  regionMeasures[timestamp]["percDiskUsed"] = computeArrayAverage(regionMeasures[timestamp]["percDiskUsed"])
	  regionMeasures[timestamp]["ipTot"] = computeArrayAverage(regionMeasures[timestamp]["ipTot"])
	  regionMeasures[timestamp]["ipAllocated"] = computeArrayAverage(regionMeasures[timestamp]["ipAllocated"])
	  regionMeasures[timestamp]["ipAssigned"] = computeArrayAverage(regionMeasures[timestamp]["ipAssigned"])
	  regionMeasures[timestamp]["nb_vm"] = computeArrayAverage(regionMeasures[timestamp]["nb_vm"])
	  
	end
      elsif granularity == "month"
	regionMeasures = Hash.new
	regionData.each do |timestamp, data|
# 	  if timestamp of month not in hash --> put in hash and put its attributes in arrays
	  monthTimestamp = timestamp.to_s.sub( %r{-[0-9]{2}T[0-9]{2}:[0-9]{2}:[0-9]{2}.[0-9]{3}Z}, "" ) 
	  if !regionMeasures.include? monthTimestamp
	    attributesRegion = Hash.new	    
	    attributesRegion["nb_users"] = [data["nb_users"]]
	    attributesRegion["nb_cores"] = [data["nb_cores"]]
	    attributesRegion["nb_cores_used"] = [data["nb_cores_used"]]
	    attributesRegion["nb_ram"] = [data["nb_ram"]]
	    attributesRegion["percRAMUsed"] = [data["percRAMUsed"]]
	    attributesRegion["cpu_allocation_ratio"] = [data["cpu_allocation_ratio"]]
	    attributesRegion["ram_allocation_ratio"] = [data["ram_allocation_ratio"]]
	    attributesRegion["nb_disk"] = [data["nb_disk"]]
	    attributesRegion["percDiskUsed"] = [data["percDiskUsed"]]
	    attributesRegion["ipTot"] = [data["ipTot"]]
	    attributesRegion["ipAllocated"] = [data["ipAllocated"]]
	    attributesRegion["ipAssigned"] = [data["ipAssigned"]]
	    attributesRegion["nb_vm"] = [data["nb_vm"]]
	    regionMeasures[monthTimestamp] = attributesRegion
# 	  if tmestamp of month in hash put its attributes in arrays
	  else
	    regionMeasures[monthTimestamp]["nb_users"].push(data["nb_users"])
	    regionMeasures[monthTimestamp]["nb_cores"].push(data["nb_cores"])
	    regionMeasures[monthTimestamp]["nb_cores_used"].push(data["nb_cores_used"])
	    regionMeasures[monthTimestamp]["nb_ram"].push(data["nb_ram"])
	    regionMeasures[monthTimestamp]["percRAMUsed"].push(data["percRAMUsed"])
	    regionMeasures[monthTimestamp]["cpu_allocation_ratio"].push(data["cpu_allocation_ratio"])
	    regionMeasures[monthTimestamp]["ram_allocation_ratio"].push(data["ram_allocation_ratio"])
	    regionMeasures[monthTimestamp]["nb_disk"].push(data["nb_disk"])
	    regionMeasures[monthTimestamp]["percDiskUsed"].push(data["percDiskUsed"])
	    regionMeasures[monthTimestamp]["ipTot"].push(data["ipTot"])
	    regionMeasures[monthTimestamp]["ipAllocated"].push(data["ipAllocated"])
	    regionMeasures[monthTimestamp]["ipAssigned"].push(data["ipAssigned"])
	    regionMeasures[monthTimestamp]["nb_vm"].push(data["nb_vm"])
	  end	  
	end
# 	Rails.logger.debug(regionMeasures)
# 	new cycle on regionMeasures to compute average
	regionMeasures.each do |timestamp, data|
	  
	  regionMeasures[timestamp]["nb_users"] = computeArrayAverage(regionMeasures[timestamp]["nb_users"])
	  regionMeasures[timestamp]["nb_cores"] = computeArrayAverage(regionMeasures[timestamp]["nb_cores"])
	  regionMeasures[timestamp]["nb_cores_used"] = computeArrayAverage(regionMeasures[timestamp]["nb_cores_used"])
	  regionMeasures[timestamp]["nb_ram"] = computeArrayAverage(regionMeasures[timestamp]["nb_ram"])
	  regionMeasures[timestamp]["percRAMUsed"] = computeArrayAverage(regionMeasures[timestamp]["percRAMUsed"])
	  regionMeasures[timestamp]["cpu_allocation_ratio"] = computeArrayAverage(regionMeasures[timestamp]["cpu_allocation_ratio"])
	  regionMeasures[timestamp]["ram_allocation_ratio"] = computeArrayAverage(regionMeasures[timestamp]["ram_allocation_ratio"])
	  regionMeasures[timestamp]["nb_disk"] = computeArrayAverage(regionMeasures[timestamp]["nb_disk"])
	  regionMeasures[timestamp]["percDiskUsed"] = computeArrayAverage(regionMeasures[timestamp]["percDiskUsed"])
	  regionMeasures[timestamp]["ipTot"] = computeArrayAverage(regionMeasures[timestamp]["ipTot"])
	  regionMeasures[timestamp]["ipAllocated"] = computeArrayAverage(regionMeasures[timestamp]["ipAllocated"])
	  regionMeasures[timestamp]["ipAssigned"] = computeArrayAverage(regionMeasures[timestamp]["ipAssigned"])
	  regionMeasures[timestamp]["nb_vm"] = computeArrayAverage(regionMeasures[timestamp]["nb_vm"])
	  
	end
      elsif granularity == "year"
	regionMeasures = Hash.new
	regionData.each do |timestamp, data|
# 	  if timestamp of year not in hash --> put in hash and put its attributes in arrays
	  yearTimestamp = timestamp.to_s.sub( %r{-[0-9]{2}-[0-9]{2}T[0-9]{2}:[0-9]{2}:[0-9]{2}.[0-9]{3}Z}, "" ) 
	  if !regionMeasures.include? yearTimestamp
	    attributesRegion = Hash.new	    
	    attributesRegion["nb_users"] = [data["nb_users"]]
	    attributesRegion["nb_cores"] = [data["nb_cores"]]
	    attributesRegion["nb_cores_used"] = [data["nb_cores_used"]]
	    attributesRegion["nb_ram"] = [data["nb_ram"]]
	    attributesRegion["percRAMUsed"] = [data["percRAMUsed"]]
	    attributesRegion["cpu_allocation_ratio"] = [data["cpu_allocation_ratio"]]
	    attributesRegion["ram_allocation_ratio"] = [data["ram_allocation_ratio"]]
	    attributesRegion["nb_disk"] = [data["nb_disk"]]
	    attributesRegion["percDiskUsed"] = [data["percDiskUsed"]]
	    attributesRegion["ipTot"] = [data["ipTot"]]
	    attributesRegion["ipAllocated"] = [data["ipAllocated"]]
	    attributesRegion["ipAssigned"] = [data["ipAssigned"]]
	    attributesRegion["nb_vm"] = [data["nb_vm"]]
	    regionMeasures[yearTimestamp] = attributesRegion
# 	  if tmestamp of year in hash put its attributes in arrays
	  else
	    regionMeasures[yearTimestamp]["nb_users"].push(data["nb_users"])
	    regionMeasures[yearTimestamp]["nb_cores"].push(data["nb_cores"])
	    regionMeasures[yearTimestamp]["nb_cores_used"].push(data["nb_cores_used"])
	    regionMeasures[yearTimestamp]["nb_ram"].push(data["nb_ram"])
	    regionMeasures[yearTimestamp]["percRAMUsed"].push(data["percRAMUsed"])
	    regionMeasures[yearTimestamp]["cpu_allocation_ratio"].push(data["cpu_allocation_ratio"])
	    regionMeasures[yearTimestamp]["ram_allocation_ratio"].push(data["ram_allocation_ratio"])
	    regionMeasures[yearTimestamp]["nb_disk"].push(data["nb_disk"])
	    regionMeasures[yearTimestamp]["percDiskUsed"].push(data["percDiskUsed"])
	    regionMeasures[yearTimestamp]["ipTot"].push(data["ipTot"])
	    regionMeasures[yearTimestamp]["ipAllocated"].push(data["ipAllocated"])
	    regionMeasures[yearTimestamp]["ipAssigned"].push(data["ipAssigned"])
	    regionMeasures[yearTimestamp]["nb_vm"].push(data["nb_vm"])
	  end	  
	end
# 	Rails.logger.debug(regionMeasures)
# 	new cycle on regionMeasures to compute average
	regionMeasures.each do |timestamp, data|
	  
	  regionMeasures[timestamp]["nb_users"] = computeArrayAverage(regionMeasures[timestamp]["nb_users"])
	  regionMeasures[timestamp]["nb_cores"] = computeArrayAverage(regionMeasures[timestamp]["nb_cores"])
	  regionMeasures[timestamp]["nb_cores_used"] = computeArrayAverage(regionMeasures[timestamp]["nb_cores_used"])
	  regionMeasures[timestamp]["nb_ram"] = computeArrayAverage(regionMeasures[timestamp]["nb_ram"])
	  regionMeasures[timestamp]["percRAMUsed"] = computeArrayAverage(regionMeasures[timestamp]["percRAMUsed"])
	  regionMeasures[timestamp]["cpu_allocation_ratio"] = computeArrayAverage(regionMeasures[timestamp]["cpu_allocation_ratio"])
	  regionMeasures[timestamp]["ram_allocation_ratio"] = computeArrayAverage(regionMeasures[timestamp]["ram_allocation_ratio"])
	  regionMeasures[timestamp]["nb_disk"] = computeArrayAverage(regionMeasures[timestamp]["nb_disk"])
	  regionMeasures[timestamp]["percDiskUsed"] = computeArrayAverage(regionMeasures[timestamp]["percDiskUsed"])
	  regionMeasures[timestamp]["ipTot"] = computeArrayAverage(regionMeasures[timestamp]["ipTot"])
	  regionMeasures[timestamp]["ipAllocated"] = computeArrayAverage(regionMeasures[timestamp]["ipAllocated"])
	  regionMeasures[timestamp]["ipAssigned"] = computeArrayAverage(regionMeasures[timestamp]["ipAssigned"])
	  regionMeasures[timestamp]["nb_vm"] = computeArrayAverage(regionMeasures[timestamp]["nb_vm"])
	  
	end
      end
    end    
    Rails.logger.debug(regionMeasures)
    return regionMeasures
  end
  
  def computeArrayAverage (array)
    sum = 0
    array_elements = 0
    array.each do |element|
      if element and element.to_i != 0
	array_elements += 1
	sum += element.to_i
      end
    end
    if sum == 0 
      return sum
    else
      return sum/array_elements#average of sum only if different from 0 or nil
    end
  end
  
  #render specific data about services of one region
  def renderServicesForRegion
    idNode = params[:nodeId]
    begin
      services = self.getServicesForNodeId(idNode)
    rescue CustomException => e
      if e.status
	render :json=>"Problem in retrieving services for region "+idNode+": "+e.data, :status => e.status
      else
	render :json=>"Problem in retrieving services for region "+idNode+": "+e.data, :status => :service_unavailable
      end
      return
    end
    
    render :json => services.to_json
  end

  #get specific data about services of one region
  def getServicesForNodeId (idNode)    
    
    begin
      servicesRegionData = self.performRequest('regions/' + idNode + '/services', false)
    rescue CustomException => e
      raise e
    end
    
    serviceNova = Hash.new
    serviceNeutron = Hash.new
    serviceCinder = Hash.new
    serviceGlance = Hash.new
    serviceKP = Hash.new
    serviceOverall = Hash.new
    serviceSanity = Hash.new
    
    serviceNova["value"] = STATUS_NA;
    serviceNova["description"] = "";
    
    
    serviceNeutron["value"] = STATUS_NA;
    serviceNeutron["description"] = "";
    
    
    serviceCinder["value"] = STATUS_NA;
    serviceCinder["description"] = "";
    
    
    serviceGlance["value"] = STATUS_NA;
    serviceGlance["description"] = "";
    
    
    serviceKP["value"] = STATUS_NA;
    serviceKP["description"] = "";
     
    serviceSanity["value"]=STATUS_NA;
    serviceSanity["description"]="";
 
    serviceOverall["value"] = STATUS_NA;
    serviceOverall["description"] = "No Messages";
    
    if servicesRegionData != nil &&  
	  servicesRegionData["measures"] != nil && 
	  servicesRegionData["measures"].count > 0 &&
	  servicesRegionData["measures"][0] != nil
      
      serviceRegionData = servicesRegionData["measures"][0]
      
      if serviceRegionData["novaServiceStatus"] != nil
	if serviceRegionData["novaServiceStatus"]["value"] != nil && serviceRegionData["novaServiceStatus"]["value"] != "undefined"
	  serviceNova["value"] = serviceRegionData["novaServiceStatus"]["value"];
	end
	if serviceRegionData["novaServiceStatus"]["description"] != nil 
	  serviceNova["description"] = serviceRegionData["novaServiceStatus"]["description"];
	end
      end
      
      if serviceRegionData["neutronServiceStatus"] != nil
	if serviceRegionData["neutronServiceStatus"]["value"] != nil && serviceRegionData["neutronServiceStatus"]["value"] != "undefined"
	  serviceNeutron["value"] = serviceRegionData["neutronServiceStatus"]["value"];
	end
	if serviceRegionData["neutronServiceStatus"]["description"] != nil
	  serviceNeutron["description"] = serviceRegionData["neutronServiceStatus"]["description"];
	end
      end
      
      if serviceRegionData["cinderServiceStatus"] != nil
	if serviceRegionData["cinderServiceStatus"]["value"] != nil && serviceRegionData["cinderServiceStatus"]["value"] != "undefined"
	  serviceCinder["value"] = serviceRegionData["cinderServiceStatus"]["value"];
	end
	if serviceRegionData["cinderServiceStatus"]["description"] != nil
	  serviceCinder["description"] = serviceRegionData["cinderServiceStatus"]["description"];
	end
      end
      
      
      if serviceRegionData["glanceServiceStatus"] != nil
	if serviceRegionData["glanceServiceStatus"]["value"] != nil && serviceRegionData["glanceServiceStatus"]["value"] != "undefined"
	  serviceGlance["value"] = serviceRegionData["glanceServiceStatus"]["value"];
	end
	if serviceRegionData["glanceServiceStatus"]["description"] != nil
	  serviceGlance["description"] = serviceRegionData["glanceServiceStatus"]["description"];
	end
      end
      
      
      if serviceRegionData["KPServiceStatus"] != nil
	if serviceRegionData["KPServiceStatus"]["value"] != nil && serviceRegionData["KPServiceStatus"]["value"] != "undefined"
	  serviceKP["value"] = serviceRegionData["KPServiceStatus"]["value"];
	end
	if serviceRegionData["KPServiceStatus"]["description"] != nil
	  serviceKP["description"] = serviceRegionData["KPServiceStatus"]["description"];
	end
      end
      
      if serviceRegionData["FiHealthStatus"] != nil
        if serviceRegionData["FiHealthStatus"]["value"] != nil && serviceRegionData["FiHealthStatus"]["value"] != "undefined"
          if serviceRegionData["FiHealthStatus"]["value"]=='green'
            serviceSanity["value"] = 1;
          elsif serviceRegionData["FiHealthStatus"]["value"]=='yellow'
            serviceSanity["value"] = 0.75;
          elsif serviceRegionData["FiHealthStatus"]["value"]=='red'
            serviceSanity["value"] = 0.0;
          end
        end
        if serviceRegionData["FiHealthStatus"]["description"] != nil
          serviceSanity["description"] = serviceRegionData["FiHealthStatus"]["description"];
        end
      end
      

      if serviceRegionData["OverallStatus"] != nil
	if serviceRegionData["OverallStatus"]["value"] != nil && serviceRegionData["OverallStatus"]["value"] != "undefined"
	  serviceOverall["value"] = serviceRegionData["OverallStatus"]["value"];
	end
# 	if serviceRegionData["OverallStatus"]["description"] != nil
# 	  serviceOverall["description"] = serviceRegionData["OverallStatus"]["description"];
# 	end
      end
      
      
#     get last message about node from db (by editing limit(1) we can have more messages)
      if idNode
      
	dbNode = Node.where(:rid => idNode).first
	    
	if dbNode	
	  
	  dbMessages = Message.where(:node_id => dbNode.id).limit(1)	
	  if dbMessages && dbMessages.size>0
	    messages = "<ul>"
	    
	    i=0
	    dbMessages = dbMessages.reverse
	    dbMessages.each do |dbMessage|
	      message = dbMessage["message"]
	      created = dbMessage["created_at"].to_datetime().to_s.sub( "T", " " ).sub( %r{:[0-9]{2}.[0-9]{2}:[0-9]{2}}, "" ) 	    
	      user = "?"
	      
	      if dbMessage["user_id"]
		dbUser = FiLabApp::User.where(:id => dbMessage["user_id"]).first
		if dbUser
		  user = dbUser.nickname	
		end
	      end	 
	      
	      if i.even?
		messages = messages+"<li style='background-color:#e8f4f6;'>"+"["+created+"] "+message
	      else
		messages = messages+"<li style='background-color:white;'>"+"["+created+"] "+message
	      end
	      
	      messages = messages+"</li>"
	      
	      i+=1
	    end
	    
	    messages = messages+"</ul>"
	    serviceOverall["description"] = messages
	  end
	  
	end      
      end
      
    end
    
    services = Hash.new
    services["Nova"] = serviceNova;
    services["Neutron"] = serviceNeutron;
    services["Cinder"] = serviceCinder;
    services["Glance"] = serviceGlance;
    services["Keystone P."] = serviceKP;
    services["FiHealthStatus"] =  serviceSanity;
    services["overallStatus"] = serviceOverall;
    
    
    dbNode = Node.where(:rid => idNode).first
    if dbNode != nil
      services["overallStatus"]["jira_project_url"] = dbNode.jira_project_url;
    end   
    
    return services
    
  end
  
  #render specific data about services of one region since a timestamp
  def renderServicesForRegionSince
    idNode = params[:nodeId]
    timestamp = params[:timestamp]
    begin
      services = self.getServicesForNodeIdSince(idNode,timestamp)
    rescue CustomException => e
      if e.status
	render :json=>"Problem in retrieving services for region "+idNode+" since "+timestamp+": "+e.data, :status => e.status
      else
	render :json=>"Problem in retrieving services for region "+idNode+" since "+timestamp+": "+e.data, :status => :service_unavailable
      end
      return
    end
    
    render :json => services.to_json
  end
  
  #get specific data about services of one region since a timestamp
  def getServicesForNodeIdSince (idNode,timestamp)    
    
    begin
      servicesRegionData = self.performRequest('regions/' + idNode + '/services?since=' + timestamp, false)
    rescue CustomException => e
      raise e
    end
    
    if servicesRegionData != nil &&  
	  servicesRegionData["measures"] != nil
    
      servicesMeasures = Hash.new
      servicesRegionData["measures"].each do |measure|
	
	serviceNova = Hash.new
	serviceNeutron = Hash.new
	serviceCinder = Hash.new
	serviceGlance = Hash.new
	serviceKP = Hash.new
	serviceOverall = Hash.new
	serviceSanity = Hash.new
	
	serviceNova["value"] = STATUS_NA;
	serviceNova["description"] = "";
	
	
	serviceNeutron["value"] = STATUS_NA;
	serviceNeutron["description"] = "";
	
	
	serviceCinder["value"] = STATUS_NA;
	serviceCinder["description"] = "";
	
	
	serviceGlance["value"] = STATUS_NA;
	serviceGlance["description"] = "";
	
	
	serviceKP["value"] = STATUS_NA;
	serviceKP["description"] = "";
	
	serviceSanity["value"]=STATUS_NA;
	serviceSanity["description"]="";
	
	serviceOverall["value"] = STATUS_NA;
	serviceOverall["description"] = "No Messages";
	
	if measure["novaServiceStatus"] != nil
	  if measure["novaServiceStatus"]["value"] != nil && measure["novaServiceStatus"]["value"] != "undefined"
	    serviceNova["value"] = measure["novaServiceStatus"]["value"];
	  end
	  if measure["novaServiceStatus"]["description"] != nil 
	    serviceNova["description"] = measure["novaServiceStatus"]["description"];
	  end
	end
	
	if measure["neutronServiceStatus"] != nil
	  if measure["neutronServiceStatus"]["value"] != nil && measure["neutronServiceStatus"]["value"] != "undefined"
	    serviceNeutron["value"] = measure["neutronServiceStatus"]["value"];
	  end
	  if measure["neutronServiceStatus"]["description"] != nil
	    serviceNeutron["description"] = measure["neutronServiceStatus"]["description"];
	  end
	end
	
	if measure["cinderServiceStatus"] != nil
	  if measure["cinderServiceStatus"]["value"] != nil && measure["cinderServiceStatus"]["value"] != "undefined"
	    serviceCinder["value"] = measure["cinderServiceStatus"]["value"];
	  end
	  if measure["cinderServiceStatus"]["description"] != nil
	    serviceCinder["description"] = measure["cinderServiceStatus"]["description"];
	  end
	end
	
	
	if measure["glanceServiceStatus"] != nil
	  if measure["glanceServiceStatus"]["value"] != nil && measure["glanceServiceStatus"]["value"] != "undefined"
	    serviceGlance["value"] = measure["glanceServiceStatus"]["value"];
	  end
	  if measure["glanceServiceStatus"]["description"] != nil
	    serviceGlance["description"] = measure["glanceServiceStatus"]["description"];
	  end
	end
	
	
	if measure["KPServiceStatus"] != nil
	  if measure["KPServiceStatus"]["value"] != nil && measure["KPServiceStatus"]["value"] != "undefined"
	    serviceKP["value"] = measure["KPServiceStatus"]["value"];
	  end
	  if measure["KPServiceStatus"]["description"] != nil
	    serviceKP["description"] = measure["KPServiceStatus"]["description"];
	  end
	end
	
	if measure["FiHealthStatus"] != nil
	  if measure["FiHealthStatus"]["value"] != nil && measure["FiHealthStatus"]["value"] != "undefined"
	    if measure["FiHealthStatus"]["value"]=='green'
	      serviceSanity["value"] = 1;
	    elsif measure["FiHealthStatus"]["value"]=='yellow'
	      serviceSanity["value"] = 0.75;
	    elsif measure["FiHealthStatus"]["value"]=='red'
	      serviceSanity["value"] = 0.0;
	    end
	  end
	  if measure["FiHealthStatus"]["description"] != nil
	    serviceSanity["description"] = measure["FiHealthStatus"]["description"];
	  end
	end
      
	if measure["OverallStatus"] != nil
	  if measure["OverallStatus"]["value"] != nil && measure["OverallStatus"]["value"] != "undefined"
	    serviceOverall["value"] = measure["OverallStatus"]["value"];
	  end
	  if measure["OverallStatus"]["description"] != nil
	    serviceOverall["description"] = measure["OverallStatus"]["description"];
	  end
	end    
	
	services = Hash.new
	services["Nova"] = serviceNova;
	services["Neutron"] = serviceNeutron;
	services["Cinder"] = serviceCinder;
	services["Glance"] = serviceGlance;
	services["Keystone P."] = serviceKP;
	services["FiHealthStatus"] =  serviceSanity;
	services["overallStatus"] = serviceOverall;
	
	
# 	dbNode = Node.where(:rid => idNode).first
# 	if dbNode != nil
# 	  services["overallStatus"]["jira_project_url"] = dbNode.jira_project_url;
# 	end   
	
	servicesMeasures[measure["timestamp"]] = services;
      end
      servicesMeasures = Hash[servicesMeasures.to_a.reverse]
      return servicesMeasures;
    end
    return nil;
  end
  
######################################################
  #render historical data about services of one region
#######################################################

  def renderHistoricalForRegion
    idNode = params[:nodeId]
    if idNode=="Spain"
       idNode="Spain2"
    elsif idNode=="Berlin"
       idNode="Berlin2"
    elsif idNode=="Lannion"
       idNode="Lannion2"
    elsif idNode=="Karlskrona"
      idNode="Karlskrona2"
    elsif idNode=="Budapest"
      idNode="Budapest2"
    elsif idNode=="Stockholm"
      idNode="Stockholm2"
    end

    begin
      services = self.getHistoricalForNodeId(idNode)
    rescue CustomException => e
      if e.status
	render :json=>"Problem in retrieving historical for region "+idNode+": "+e.data, :status => e.status
      else
	render :json=>"Problem in retrieving historical for region "+idNode+": "+e.data, :status => :service_unavailable
      end
      return
    end

    render :json => services.to_json
  end

  #get historical data about services of one region
  def getHistoricalForNodeId (idNode)

    #if ENV["RAILS_ENV"] != "test"
    #  raise "TODO: available only for testing/demo purposes!"
    #end

    require 'json'
    require 'date'

    result = Hash.new
    result['measures'] = Array.new
    #sample = JSON.parse(File.read('test/assets/historical.json'))['measures'][0]

    begin
      timeago = Time.at(3.months.ago).strftime("%y-%m-%d")
      servicesRegionHistoricalData = self.performRequest('regions/' + idNode + '/services?since=' + timeago + 'T00:00:00&aggregate=d', false)
      if servicesRegionHistoricalData != nil &&  servicesRegionHistoricalData["measures"] != nil
        #logger.info servicesRegionHistoricalData["measures"]
        result['measures']=servicesRegionHistoricalData["measures"]
      end 
    rescue CustomException => e
      raise e
    end

    year = Date.today.year
    yday = Date.today.yday
    seed = idNode.sum(2048)
    prng = Random.new(seed)

    #for day in 1..yday
    #  timestamp = Date.ordinal(year, day).strftime('%Y-%m-%d 00.00')
    #  fihealth = sample['FiHealthStatus'].clone
    #  random = prng.rand(-10..100)
    #  fihealth['value'] = random > 1 ? STATUS_OK : random < 0 ? STATUS_NOK : STATUS_POK
    #  sample['timestamp'] = timestamp
    #  sample['FiHealthStatus'] = fihealth
    #  result['measures'].push(sample.clone)
    #end

    return result

  end

  #render data about services of all regions
  def renderServices
    
    begin
      regionsData = self.getRegionsData("Histogram")
    rescue CustomException => e
      if e.status
	render :json=>"Problem in retrieving data for all nodes: "+e.data, :status => e.status
      else
	render :json=>"Problem in retrieving data for all nodes: "+e.data, :status => :service_unavailable
      end
      return
    end
    
    if regionsData == nil
      render :json=>"Problem in retrieving data: no data", :status => :service_unavailable
      return
    end
    
    attributesRegionsServices = regionsData["regions"]
    
    
    attributesRegionsServices.each do |key,regionData|
      
      begin
	services = self.getServicesForNodeId(regionData["id"])
      rescue CustomException => e
	if e.status
	  render :json=>"Problem in retrieving services for region "+regionData["id"]+": "+e.data, :status => e.status
	else
	  render :json=>"Problem in retrieving services for region "+regionData["id"]+": "+e.data, :status => :service_unavailable
	end
	return
      end
      
      regionData["services"] = services;
      
      
#       attributesRegionsServices[regionData["id"]]["Nova"]["value"] = serviceRegionData["novaServiceStatus"]["value"];
#       attributesRegionsServices[regionData["id"]]["Nova"]["description"] = serviceRegionData["novaServiceStatus"]["description"];
      
#       attributesRegionsServices[regionData["id"]]["Neutron"]["value"] = serviceRegionData["neutronServiceStatus"]["value"];
#       attributesRegionsServices[regionData["id"]]["Neutron"]["description"] = serviceRegionData["neutronServiceStatus"]["description"];

#       attributesRegionsServices[regionData["id"]]["Cinder"]["value"] = serviceRegionData["cinderServiceStatus"]["value"];
#       attributesRegionsServices[regionData["id"]]["Cinder"]["description"] = serviceRegionData["cinderServiceStatus"]["description"];
      
#       attributesRegionsServices[regionData["id"]]["Glance"]["value"] = serviceRegionData["glanceServiceStatus"]["value"];
#       attributesRegionsServices[regionData["id"]]["Glance"]["description"] = serviceRegionData["glanceServiceStatus"]["description"];
      
#       attributesRegionsServices[regionData["id"]]["IDM"]["value"] = serviceRegionData["KPServiceStatus"]["value"];
#       attributesRegionsServices[regionData["id"]]["IDM"]["description"] = serviceRegionData["KPServiceStatus"]["description"];
      
#       points = 0
#       if serviceRegionData["novaServiceStatus"]["value"] == STATUS_OK
# 	points+=2;
#       end
# 	
#       if serviceRegionData["neutronServiceStatus"]["value"] == STATUS_OK
# 	points+=2;
#       end
# 	
#       if serviceRegionData["cinderServiceStatus"]["value"] == STATUS_OK
# 	points+=2;
#       end
# 	
#       if serviceRegionData["glanceServiceStatus"]["value"] == STATUS_OK
# 	points+=2;
#       end
# 	
#       if serviceRegionData["KPServiceStatus"]["value"] == STATUS_OK
# 	points+=2;
#       end
# 	
#       if points == 10 
# 	attributesRegionsServices[regionData["id"]]["services"]["overallStatus"] = STATUS_OK;
#       elsif points <= 5 
# 	attributesRegionsServices[regionData["id"]]["services"]["overallStatus"] = STATUS_NOK;
#       elsif 
# 	attributesRegionsServices[regionData["id"]]["services"]["overallStatus"] = STATUS_POK;
#       end

    end
#     puts attributesRegionsServices
    render :json => attributesRegionsServices.to_json
      
  end
  
  def renderRegionIdListFromDb
    
    allDbNodes = Node.order(:rid).all
    allNodes = Array.new;
    allNodesNames = Array.new;
    if !allDbNodes.nil?
      allDbNodes.each do |singleNode|
	allNodes.push singleNode.rid;
	allNodesNames.push singleNode.name;
      end
    end
    
    nodesList = Hash.new
    nodesList["list"] = allNodes;
    nodesList["names"] = allNodesNames;
    nodesList["successMsg"] = FiLabInfographics.jira_success_message;
    render :json => nodesList.to_json
    
  end
  
  #render list of all hosts of one region
  def renderHostsListForRegion
    idNode = params[:nodeId]
    begin
      hosts = self.getHostsListForNodeId(idNode)
    rescue CustomException => e
      if e.status
	render :json=>"Problem in retrieving hosts list for region "+idNode+": "+e.data, :status => e.status
      else
	render :json=>"Problem in retrieving hosts list for region "+idNode+": "+e.data, :status => :service_unavailable
      end
      return
    end
    
    render :json => hosts.to_json
  end
  
  #get list of all hosts of one region
  def getHostsListForNodeId (idNode)
    begin
      hostsData = self.performRequest('regions/'+idNode+'/hosts', true)
    rescue CustomException => e
      raise e
      return
    end
    
    
    if hostsData != nil
      idHosts = [] 
      
      hostsData["hosts"].each do |host|
		idHosts.push(host["id"])
      end
      
      totValues = Hash.new

      totValues["total_hosts_ids"] = idHosts;
      totValues["total_hosts_count"] = idHosts.count;
      
      return totValues
      
    end
    return nil
  end
  
  #render specific data about host of one region
  def renderHostForRegion
    idNode = params[:nodeId]
    idHost = params[:host_id]
    begin
      hosts = self.getHostForNodeId(idHost,idNode)
    rescue CustomException => e
      if e.status
	render :json=>"Problem in retrieving data about host "+idHost+" for region "+idNode+": "+e.data, :status => e.status
      else
	render :json=>"Problem in retrieving data about host "+idHost+" for region "+idNode+": "+e.data, :status => :service_unavailable
      end
      return
    end
    
    render :json => hosts.to_json
  end
  
  #get specific data about host of one region
  def getHostForNodeId (idHost,idNode)
    begin
      hostData = self.performRequest('regions/'+idNode+'/hosts/'+idHost, true)
    rescue CustomException => e
      raise e
    end
    
    if hostData != nil
            
      attributesHost = Hash.new
      attributesHost["id"] = hostData["hostid"]
      
      if hostData["ipAddresses"]!= nil && hostData["ipAddresses"].size >0
	ipAddrs = []
	hostData["ipAddresses"].each do |ip|
	  ipAddrs.push(ip["ipAddress"])
	end
	attributesHost["ipList"] = ipAddrs
      end
      
      if hostData["measures"]!= nil && hostData["measures"].size >0
      
	if hostData["measures"][0]["percCPULoad"] != nil && hostData["measures"][0]["percCPULoad"]["value"] != nil
	  attributesHost["percCPULoad"] = hostData["measures"][0]["percCPULoad"]["value"]
	end
	if hostData["measures"][0]["percRAMUsed"] != nil && hostData["measures"][0]["percRAMUsed"]["value"] != nil
	  attributesHost["percRAMUsed"] = hostData["measures"][0]["percRAMUsed"]["value"]
	end
	if hostData["measures"][0]["percDiskUsed"] != nil && hostData["measures"][0]["percDiskUsed"]["value"] != nil
	  attributesHost["percDiskUsed"] = hostData["measures"][0]["percDiskUsed"]["value"]
	end   
	if hostData["measures"][0]["sysUptime"] != nil && hostData["measures"][0]["sysUptime"]["value"] != nil
	  attributesHost["sysUptime"] = hostData["measures"][0]["sysUptime"]["value"]
	end  
      end    
      
      return attributesHost
      
    end 
    return nil
  end 
  
  #render list of all VM of one region
  def renderVMsListForRegion
    idNode = params[:nodeId]
    begin
      vms = self.getVMsListForNodeId(idNode)
    rescue CustomException => e
      if e.status
	render :json=>"Problem in retrieving vms list for region "+idNode+": "+e.data, :status => e.status
      else
	render :json=>"Problem in retrieving vms list for region "+idNode+": "+e.data, :status => :service_unavailable
      end
      return
    end
    
    render :json => vms.to_json
  end
  
  #get list of all VM of one region
  def getVMsListForNodeId (idNode)
    begin
      vmsData = self.performRequest('regions/'+idNode+'/vms', false)
    rescue CustomException => e
      raise e
      return
    end
    
    
    if vmsData != nil
      idVms = [] 
      
      vmsData["vms"].each do |vm|
		idVms.push(vm["id"])
      end
      
      totValues = Hash.new

      totValues["total_vms_ids"] = idVms;
      totValues["total_vms_count"] = idVms.count;
      
      return totValues
      
    end
    return nil
  end
  
  #render specific data about VM of one region
  def renderVMForRegion
    idNode = params[:nodeId]
    idVm = params[:vm_id]
    begin
      vms = self.getVMForNodeId(idVm,idNode)
    rescue CustomException => e
      if e.status
	render :json=>"Problem in retrieving data about vm "+idVm+" for region "+idNode+": "+e.data, :status => e.status
      else
	render :json=>"Problem in retrieving data about vm "+idVm+" for region "+idNode+": "+e.data, :status => :service_unavailable
      end
      return
    end
    
    render :json => vms.to_json
  end
  
  #get specific data about VM of one region
  def getVMForNodeId (idVm,idNode)
    begin
      vmData = self.performRequest('regions/'+idNode+'/vms/'+idVm, false)
    rescue CustomException => e
      raise e
    end
    
    if vmData != nil
            
      attributesVm = Hash.new
      attributesVm["id"] = vmData["vmid"]
      
      if vmData["ipAddresses"]!= nil && vmData["ipAddresses"].size >0
	ipAddrs = []
	vmData["ipAddresses"].each do |ip|
	  ipAddrs.push(ip["ipAddress"])
	end
	attributesVm["ipList"] = ipAddrs
      end
      
      if vmData["measures"]!= nil && vmData["measures"].size >0
      
	if vmData["measures"][0]["percCPULoad"] != nil && vmData["measures"][0]["percCPULoad"]["value"] != nil
	  attributesVm["percCPULoad"] = vmData["measures"][0]["percCPULoad"]["value"]
	end
	if vmData["measures"][0]["percRAMUsed"] != nil && vmData["measures"][0]["percRAMUsed"]["value"] != nil
	  attributesVm["percRAMUsed"] = vmData["measures"][0]["percRAMUsed"]["value"]
	end
	if vmData["measures"][0]["percDiskUsed"] != nil && vmData["measures"][0]["percDiskUsed"]["value"] != nil
	  attributesVm["percDiskUsed"] = vmData["measures"][0]["percDiskUsed"]["value"]
	end   
	if vmData["measures"][0]["sysUptime"] != nil && vmData["measures"][0]["sysUptime"]["value"] != nil
	  attributesVm["sysUptime"] = vmData["measures"][0]["sysUptime"]["value"]
	end  
      end    
      
      return attributesVm
      
    end 
    return nil
  end
  
#   def renderVms
#     
#     regionsData = self.performRequest('regions')
#     
#     idRegions = [] 
#     
#     regionsData.each do |contextElementResponse|
#       contextElementResponse["contextElementResponse"].each do |contextElement|   
# 	contextElement["contextElement"].each do |entityId|
# 	  entityId["entityId"].each do |id|
# 	    id["id"].each do |idRegion|
# 	      idRegions.push(idRegion)
# 	    end
# 	  end
# 	end
#       end
#     end
#     
#     attributesRegionsVMs = Hash.new
#     
#     idRegions.each do |idRegion|
#       regionData = self.performRequest('region/' + idRegion)
#       
#       locationVM = idRegion
#       vmsRegionData = self.performRequest('region/' + idRegion + '/VM')
#       idVMs = [] 
#     
#       vmsRegionData.each do |contextElementResponse|
# 	contextElementResponse["contextElementResponse"].each do |contextElement|   
# 	  contextElement["contextElement"].each do |entityId|
# 	    entityId["entityId"].each do |id|
# 	      id["id"].each do |idVm|
# 		idVMs.push(idVm)
# 	      end
# 	    end
# 	  end
# 	end
#       end
#       
#       attributesVMs = Hash.new
#       
#       idVMs.each do |idVM|
# 	vmRegionData = self.performRequest('regions/' + idRegion + '/VM/' + idVM)
#       
# 	attributesVM = Hash.new
# 
# 	vmRegionData.each do |contextElementResponse|
# 	  contextElementResponse["contextElementResponse"].each do |contextElement|
# 	    contextElement["contextElement"].each do |contextAttributeList|
# 	      contextAttributeList["contextAttributeList"].each do |contextAttribute|
# 		contextAttribute["contextAttribute"].each do |attribute|
# 		  attributesVM[attribute["name"].first] = attribute["contextValue"].first
# 		end
# 	      end
# 	    end
# 	  end
# 	end
# 
# 	attributesVMs[idVM] = attributesVM
# 
#       end
#       
#       attributesRegionsVMs [locationVM] = attributesVMs
#       
#     end
#     
#     render :json => attributesRegionsVMs.to_json
#       
#   end
  
end
