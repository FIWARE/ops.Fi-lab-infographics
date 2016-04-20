class CustomException < Exception
  attr_accessor :data
  attr_accessor :status
  def initialize(data, status)
    @data = data
    @status = status
  end
end

class InstitutionController < ApplicationController
#   protect_from_forgery except: :renderInstitutions
  skip_before_filter :verify_authenticity_token, :if => Proc.new { |c| c.request.format == 'application/json' }
  
  def renderInstitutions
    
    idNode = params[:idNode]
    category = params[:category]
    
    dbNode = nil;
    dbCategory = nil;
    dbInstitutions = nil;
    
    if idNode	  
      dbNode = Node.where(:rid => idNode).first	 
    end
    
    if category	  
      dbCategory = Category.find(:first, :conditions => ["lower(name) = ?", category.downcase]) 
    end
    
    if dbNode#take institutions of node (category is meaningless, because it will be equal to node's category)  
      dbInstitutions = Institution.includes(:nodes).where("fi_lab_infographics_nodes_institutions.node_id = ?", dbNode.id).order(name: :asc)
#       if dbCategory == nil#take all institutions of node
# 	dbInstitutions = Institution.includes(:nodes).where("fi_lab_infographics_nodes_institutions.node_id = ?", dbNode.id).order(name: :asc)
#       else	    
# 	dbInstitutions = Institution.includes(:nodes).where("fi_lab_infographics_nodes_institutions.node_id = ?", dbNode.id).where("fi_lab_infographics_nodes.category_id = ?", dbCategory.id).order(name: :asc).distinct
#       end
    elsif idNode == nil #take all institutions
      if dbCategory == nil #take all institutions of node
	dbInstitutions = Institution.order(name: :asc)
      else	    
	dbInstitutions = Institution.includes(:nodes).where("fi_lab_infographics_nodes.category_id = ?", dbCategory.id).order(name: :asc).distinct
      end
    end
    
    if dbInstitutions == nil
      render :json=>[], :status => 200
    else 	
      institutions = []
      
      dbInstitutions.each do |dbInstitution|
	institution = Hash.new
	institution["id"] = dbInstitution["id"]
	institution["name"] = dbInstitution["name"]
	institution["logo"] = dbInstitution["logo"]
	institution["description"] = dbInstitution["description"]
	institution["link"] = dbInstitution["link"]
	
	institutions.push(institution)
      end
      
      render :json => institutions.to_json	
    end
  end  
  
  def renderInstitutionsGroupedForCategory
    
    dbCategories = Category.order(id: :asc)
    
    if dbCategories == nil
      render :json=>[], :status => 200
      return
    end
    
    categories = []
    
    dbCategories.each do |dbCategory|
      category = Hash.new
      category["id"] = dbCategory.id;
      category["name"] = dbCategory.name;
      category["logo"] = dbCategory.logo;
      category["description"] = dbCategory.description;
      
      dbInstitutions = Institution.includes(:nodes).where("fi_lab_infographics_nodes.category_id = ?", dbCategory.id).order(name: :asc).distinct
      
      institutions = []
      if dbInstitutions != nil	 	
	
	dbInstitutions.each do |dbInstitution|
	  institution = Hash.new
	  institution["id"] = dbInstitution["id"]
	  institution["name"] = dbInstitution["name"]
	  institution["logo"] = dbInstitution["logo"]
	  institution["description"] = dbInstitution["description"]
	  institution["link"] = dbInstitution["link"]
	  
	  institutions.push(institution)	
	end
      end
      category["institutions"] = institutions  
      categories.push(category)
    end    
    render :json => categories.to_json
  end 
  
  def deleteInstitution
    
    idUser = params[:idUser]#must be admin
    idInstitution = params[:idInstitution]
    
    
    if idUser
      if idInstitution
	dbUser = FiLabApp::User.where(:id => idUser).first
	  
	if dbUser == nil
	  render :json=>"User not found in db: "+idUser, :status => :service_unavailable
	elsif !view_context.user_role(dbUser,'Provider')
	  render :json=>"User is not a Provider: "+idUser, :status => 401
	else
	  dbInstitution = Institution.where(:id => idInstitution).first
	  
	  if dbInstitution == nil
	    render :json=>"Institution not found in db: "+idInstitution, :status => :service_unavailable
	  else
	    Institution.destroy(idInstitution)
	    
	    response = Hash.new
	    response["idMessage"] = "Institution deleted"
	    render :json=>response, :status => 200
	  end
	end
      else 
	response = Hash.new
	response["status"] = "Id Institution not set"
	render :json=>response, :status => :service_unavailable
      end
    else 
      response = Hash.new
      response["status"] = "User id not set: user not logged"
      render :json=>response, :status => 401
    end    
    
  end
  
  def deleteInstitutionAssociation
    
    idUser = params[:idUser]#must be owner of node
    idInstitution = params[:idInstitution]
    idNode = params[:nodeId]
    
    
    if idUser
      if idInstitution
	if idNode
	  dbUser = FiLabApp::User.where(:id => idUser).first
	  dbNode = Node.includes(:institutions).where(:rid => idNode).first
	  
	  if dbUser == nil
	    render :json=>"User not found in db: "+idUser, :status => :service_unavailable
	  elsif dbNode == nil
	      render :json=>"Node not found in db: "+idNode, :status => :service_unavailable
	  elsif !view_context.user_role(dbUser,'InfrastructureOwner')
	    render :json=>"User is not an Infrastructure Owner: "+idUser, :status => 401
	  elsif dbUser.node_id == nil or dbUser.node_id != dbNode.id
	    render :json=>"User is not the Infrastructure Owner of node: "+idNode, :status => 401
	  else
	    
	    dbInstitution = Institution.where(:id => idInstitution).first
	    
	    
	    if dbInstitution == nil
	      render :json=>"Institution not found in db: "+idInstitution, :status => :service_unavailable
	    else
	      dbNode.institutions.destroy(dbInstitution)
	      
	      response = Hash.new
	      response["idMessage"] = "Institution association deleted"
	      render :json=>response, :status => 200
	    end
	  end
	else 
	  response = Hash.new
	  response["status"] = "Id Node not set"
	  render :json=>response, :status => :service_unavailable
	end
      else 
	response = Hash.new
	response["status"] = "Id Institution not set"
	render :json=>response, :status => :service_unavailable
      end
    else 
      response = Hash.new
      response["status"] = "User id not set: user not logged"
      render :json=>response, :status => 401
    end    
    
  end
  
#   def updateUser
#     
#     idAdminUser = params[:idAdminUser]
#     idUser = params[:idUser]
#     idNode = params[:idNode]
#     
# #     Rails.logger.info(idNode+"-"+idUser+"-"+message);
#     
#     if idNode
#       if idAdminUser
# 	if idUser
# 	  dbAdminUser = FiLabApp::User.where(:id => idAdminUser).first
# 	  
# 	  if dbAdminUser == nil
# 	    render :json=>"Admin User not found in db: "+idAdminUser, :status => :service_unavailable
# 	  elsif !view_context.user_role(dbAdminUser,'Provider')
# 	    render :json=>"Admin User is not a Provider: "+idAdminUser, :status => 401
# 	  else
# 	    
# 	    dbUser = FiLabApp::User.where(:id => idUser).first
# 	      
# 	    if dbUser == nil
# 	      render :json=>"User not found in db: "+idMessage, :status => :service_unavailable
# 	    else
# 	       if idNode == "none"
# 		 FiLabApp::User.update(idUser, :node => nil)
# 		
# 		response = Hash.new
# 		response["idMessage"] = "User updated"
# 		render :json=>response, :status => 200
# 	       else
# 		dbNode = Node.where(:rid => idNode).first	    
# 	      
# 		if dbNode == nil
# 		  render :json=>"Node not found in db: "+idNode, :status => :service_unavailable
# 		else
# 		  FiLabApp::User.update(idUser, :node => dbNode)
# 		
# 		  response = Hash.new
# 		  response["idMessage"] = "User updated"
# 		  render :json=>response, :status => 200
# 		end
# 	       end	       
# 	    end
# 	    
# 	  end
# 	else 
# 	  response = Hash.new
# 	  response["status"] = "Id User not set"
# 	  render :json=>response, :status => :service_unavailable
# 	end
#       else 
# 	response = Hash.new
# 	response["status"] = "Admin User id not set: user not logged"
# 	render :json=>response, :status => 401
#       end 
#     else
#       response = Hash.new
#       response["status"] = "Node not set"
#       render :json=>response, :status => :service_unavailable
#     end
#     
#   end
  
end
