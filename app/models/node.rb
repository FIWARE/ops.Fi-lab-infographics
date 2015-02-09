class Node < ActiveRecord::Base
  self.table_name = "fi_lab_infographics_nodes"
  has_one :message, class_name: "Message"
  has_one :owner, class_name: "FiLabApp::User"
  belongs_to :category, class_name: "Category", foreign_key: "category_id"
#   belongs_to :owner, class_name: "FiLabApp::User", foreign_key: "node_id"
#   belongs_to :message, class_name: "Message", foreign_key: "node_id"
  has_and_belongs_to_many :institutions, :class_name => "Institution", :join_table => :fi_lab_infographics_nodes_institutions
end
