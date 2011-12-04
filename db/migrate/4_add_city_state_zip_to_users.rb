
migration 4, :add_city_state_zip_to_users do
	up do
		modify_table :users do
			add_column :city, String
			add_column :state, String
			add_column :zip, Integer
		end
	end

	down do
		modify_table :users do
			puts "sqlite3 cannot drop columns"
		end
	end
end
