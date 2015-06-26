class Addcommentstonotes < ActiveRecord::Migration
  def change
  	add_column :notes, :comments, :string
  end
end
