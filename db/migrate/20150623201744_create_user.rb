class CreateUser < ActiveRecord::Migration
  def change
  	create_table :users do |t|
  		t.string :user_email, null: false
  		t.string :user_psw, null: false
  		t.string :user_name, null: false
  		t.string :user_tel, null: false
  	end
  end
end
