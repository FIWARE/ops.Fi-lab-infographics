# This migration comes from fi_lab_app (originally 20150415051006)
class AddActorIdToFiLabAppUsers < ActiveRecord::Migration
  def change
    add_column :fi_lab_app_users, :actorid, :string
  end
end
