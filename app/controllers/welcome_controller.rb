class WelcomeController < FiLabApp::ApplicationController
 include FiLabApp::UserHelper
 #before_filter :authenticate_user!

  def info
  end

  def status
  end

  def historical
  end

  def node 
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
