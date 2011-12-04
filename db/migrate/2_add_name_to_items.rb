
migration 2, :add_name_to_items do
	up do
		modify_table :items do
			add_column :name, String
		end
	end

	down do
		modify_table :items do
			puts "sqlite3 cannot drop columns"
		end
	end
end
