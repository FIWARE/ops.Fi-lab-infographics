class CustomException < Exception
  attr_accessor :data
  attr_accessor :status
  def initialize(data, status)
    @data = data
    @status = status
  end
end

class MessageController < ApplicationController
#   protect_from_forgery :except => [:createMessage]
#   skip_before_filter :verify_authenticity_token, :if => Proc.new { |c| c.request.format == 'application/json' }
  
  def createMessage
    
    idNode = params[:idNode]
    idUser = params[:idUser]
    message = params[:message]
    
#     Rails.logger.info(idNode+"-"+idUser+"-"+message);
    
    if idNode
      if idUser
	if message
	  dbNode = Node.where(:rid => idNode).first
	  
	  if dbNode == nil
	    render :json=>"Node not found in db: "+idNode, :status => :service_unavailable
	  else 
	    dbUser = FiLabApp::User.where(:id => idUser).first
	    
	    if dbUser == nil
	      render :json=>"User not found in db: "+idUser, :status => :service_unavailable
	    else
	      newMessage = Message.new
	      newMessage.owner = dbUser
	      newMessage.node = dbNode
	      newMessage.message = message
	      newMessage.created_at = DateTime.now#Date.today.to_datetime
	      newMessage.save
	      
	      response = Hash.new
	      response["idMessage"] = "Message set"
	      render :json=>response, :status => 200
	    end
	  end
	else 
	  response = Hash.new
	  response["status"] = "Message not set"
	  render :json=>response, :status => :service_unavailable
	end
      else 
	response = Hash.new
	response["status"] = "User id not set: user not logged"
	render :json=>response, :status => 401
      end
    else 
      response = Hash.new
      response["status"] = "Node id not set"
      render :json=>response, :status => :service_unavailable
    end
    
  end
  
  def renderMessages
    
    idNode = params[:idNode]
    since = params[:since]
    
    if idNode
      
      dbNode = Node.where(:rid => idNode).first
	  
      if dbNode == nil
	render :json=>"Node not found in db: "+idNode, :status => :not_found
      else 
	dbMessages = nil
	if since
	  dbMessages = Message.where("node_id = ? AND created_at >= ?", dbNode.id, since).order('created_at DESC')#"created_at >= ?", Time.zone.now.beginning_of_day
	else 
	  dbMessages = Message.where(:node_id => dbNode.id).order('created_at DESC').limit(10)#.reverse
	end
	
	if dbMessages == nil
	  render :json=>[], :status => 200
	else 	
	  messages = []
	  
	  dbMessages.each do |dbMessage|
	    message = Hash.new
	    message["id"] = dbMessage["id"]
	    message["message"] = dbMessage["message"]
	    message["created_at"] = dbMessage["created_at"]
	    message["user_id"] = dbMessage["user_id"]
	    
	    if dbMessage["user_id"]
	      dbUser = FiLabApp::User.where(:id => dbMessage["user_id"]).first
	      if dbUser
		message["user_name"] = dbUser.nickname
	      else
		message["user_name"] = ""
	      end
	    end
	    messages.push(message)
	  end
	  
	  render :json => messages.to_json	
	end
      end
      
    else 
      response = Hash.new
      response["status"] = "Node id not set"
      render :json=>response, :status => :service_unavailable
    end
    
  end
  
  def deleteMessage
    
    idUser = params[:idUser]
    idMessage = params[:idMessage]
    
#     Rails.logger.info(idNode+"-"+idUser+"-"+message);
    
    
    if idUser
      if idMessage
	dbUser = FiLabApp::User.where(:id => idUser).first
	  
	if dbUser == nil
	  render :json=>"User not found in db: "+idUser, :status => :service_unavailable
	else
	  dbMessage = Message.where(:id => idMessage, :owner => dbUser).first
	  
	  if dbMessage == nil
	    render :json=>"Message created by user "+idUser+" not found in db: "+idMessage, :status => :service_unavailable
	  else
	    Message.destroy(idMessage)
	    
	    response = Hash.new
	    response["idMessage"] = "Message deleted"
	    render :json=>response, :status => 200
	  end
	end
      else 
	response = Hash.new
	response["status"] = "Id Message not set"
	render :json=>response, :status => :service_unavailable
      end
    else 
      response = Hash.new
      response["status"] = "User id not set: user not logged"
      render :json=>response, :status => 401
    end    
    
  end
  
  def updateMessage
    
    idUser = params[:idUser]
    idMessage = params[:idMessage]
    message = params[:message]
    
#     Rails.logger.info(idNode+"-"+idUser+"-"+message);
    
    if message
      if idUser
	if idMessage
	  dbUser = FiLabApp::User.where(:id => idUser).first
	    
	  if dbUser == nil
	    render :json=>"User not found in db: "+idUser, :status => :service_unavailable
	  else
	    dbMessage = Message.where(:id => idMessage, :owner => dbUser).first
	    
	    if dbMessage == nil
	      render :json=>"Message created by user "+idUser+" not found in db: "+idMessage, :status => :service_unavailable
	    else
	      Message.update(idMessage, :message => message)
	      
	      response = Hash.new
	      response["idMessage"] = "Message updated"
	      render :json=>response, :status => 200
	    end
	  end
	else 
	  response = Hash.new
	  response["status"] = "Id Message not set"
	  render :json=>response, :status => :service_unavailable
	end
      else 
	response = Hash.new
	response["status"] = "User id not set: user not logged"
	render :json=>response, :status => 401
      end 
    else
      response = Hash.new
      response["status"] = "Message not set"
      render :json=>response, :status => :service_unavailable
    end
    
  end
  
end
