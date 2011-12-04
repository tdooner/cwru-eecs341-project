
migration 3, :add_desc_to_items do
	up do
		modify_table :items do
			add_column :desc, Text
		end
	end

	down do
		modify_table :items do
			puts "sqlite3 cannot drop columns"
		end
	end
end
