class Category < ActiveRecord::Base
  self.table_name = "fi_lab_infographics_node_categories"
  has_one :node, class_name: "Node"
#   belongs_to :node, class_name: "Node", foreign_key: "node_id"
end
