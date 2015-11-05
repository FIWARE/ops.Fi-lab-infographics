# This migration comes from fi_lab_app (originally 20150513100956)
# This migration comes from fi_lab_app (originally 20150513100956)
class RemoveColumnUidFromFilabAppUser < ActiveRecord::Migration
  def change1
    change_table :fi_lab_app_users do |t|
      t.remove :uid
      t.remove :actorid
      t.rename :nickname, :uid
    end
  end

  def change2
    change_table :fi_lab_app_organizations do |t|
      t.remove :rid
      t.rename :actorid, :uid
    end
  end

end
