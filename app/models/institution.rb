class Institution < ActiveRecord::Base
  self.table_name = "fi_lab_infographics_institutions"
  has_and_belongs_to_many :nodes, :class_name => "Node", :join_table => :fi_lab_infographics_nodes_institutions
#   belongs_to :category, class_name: "Category", foreign_key: "category_id"
end
