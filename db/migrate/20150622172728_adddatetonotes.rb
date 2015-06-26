class Adddatetonotes < ActiveRecord::Migration
	def change
		add_column :notes, :date, :string
	end
end
