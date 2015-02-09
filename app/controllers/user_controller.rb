class CustomException < Exception
  attr_accessor :data
  attr_accessor :status
  def initialize(data, status)
    @data = data
    @status = status
  end
end

class UserController < ApplicationController
  
  def renderUsers
    
    idAdminUser = params[:idUser]
    
    if idAdminUser
      
      dbAdminUser = FiLabApp::User.where(:id => idAdminUser).first
	  
      if dbAdminUser == nil
	render :json=>"User not found in db: "+idAdminUser, :status => :service_unavailable
      elsif !view_context.user_role(dbAdminUser,'Provider')
	render :json=>"User is not a Provider: "+idAdminUser, :status => 401
      else
	
	dbUsers = FiLabApp::User.find(:all, :order => "name ASC")
	
	if dbUsers == nil
	  render :json=>[], :status => 200
	else 	
	  users = []
	  
	  dbUsers.each do |dbUser|
	    user = Hash.new
	    user["id"] = dbUser["id"]
	    user["name"] = dbUser["name"]
	    user["nickname"] = dbUser["nickname"]
	    user["email"] = dbUser["email"]
	    
	    if dbUser.node
	      user["node_id"] = dbUser.node.rid
	      user["node_name"] = dbUser.node.name
	    else
	      user["node_id"] = "none"
	      user["node_name"] = "none"
	    end
	    
	    users.push(user)
	  end
	  
	  render :json => users.to_json	
	end
      end
      
    else 
      response = Hash.new
      response["status"] = "Admin User id not set"
      render :json=>response, :status => :service_unavailable
    end
    
  end
  
  def updateUser
    
    idAdminUser = params[:idAdminUser]
    idUser = params[:idUser]
    idNode = params[:idNode]
    
#     Rails.logger.info(idNode+"-"+idUser+"-"+message);
    
    if idNode
      if idAdminUser
	if idUser
	  dbAdminUser = FiLabApp::User.where(:id => idAdminUser).first
	  
	  if dbAdminUser == nil
	    render :json=>"Admin User not found in db: "+idAdminUser, :status => :service_unavailable
	  elsif !view_context.user_role(dbAdminUser,'Provider')
	    render :json=>"Admin User is not a Provider: "+idAdminUser, :status => 401
	  else
	    
	    dbUser = FiLabApp::User.where(:id => idUser).first
	      
	    if dbUser == nil
	      render :json=>"User not found in db: "+idMessage, :status => :service_unavailable
	    else
	       if idNode == "none"
		 FiLabApp::User.update(idUser, :node => nil)
		
		response = Hash.new
		response["idMessage"] = "User updated"
		render :json=>response, :status => 200
	       else
		dbNode = Node.where(:rid => idNode).first	    
	      
		if dbNode == nil
		  render :json=>"Node not found in db: "+idNode, :status => :service_unavailable
		else
		  FiLabApp::User.update(idUser, :node => dbNode)
		
		  response = Hash.new
		  response["idMessage"] = "User updated"
		  render :json=>response, :status => 200
		end
	       end	       
	    end
	    
	  end
	else 
	  response = Hash.new
	  response["status"] = "Id User not set"
	  render :json=>response, :status => :service_unavailable
	end
      else 
	response = Hash.new
	response["status"] = "Admin User id not set: user not logged"
	render :json=>response, :status => 401
      end 
    else
      response = Hash.new
      response["status"] = "Node not set"
      render :json=>response, :status => :service_unavailable
    end
    
  end
  
end
