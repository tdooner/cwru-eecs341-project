require 'open-uri'
require 'csv'

migration 1, :create_zip_code_table do
    up do
        # To get us on-track with migrations:
        create_migration_info_table_if_needed
        execute("INSERT INTO #{migration_info_table} (#{migration_name_column}) VALUES ('add_city_state_zip_to_users')")  
        execute("INSERT INTO #{migration_info_table} (#{migration_name_column}) VALUES ('add_name_to_items')")
        execute("INSERT INTO #{migration_info_table} (#{migration_name_column}) VALUES ('add_desc_to_items')")
        # Okay, all should be well, now.

        create_table :zip_codes do
            column :id, Serial
            column :zip, Integer, :unique_index => true
            column :city_name, String
            column :latitude, Decimal
            column :longitude, Decimal
        end
        open('http://federalgovernmentzipcodes.us/free-zipcode-database-Primary.csv') do |f|
            CSV.new(f, {:headers=>:first_row}).each do |r|
                execute("INSERT INTO zip_codes (zip, city_name, latitude, longitude) VALUES (?,?,?,?)", r["Zipcode"].to_i, r["City"], r["Lat"].to_f, r["Long"].to_f)
            end
        end
    end

    down do
        drop_table :zip_codes  # That was easy!

        execute("DELETE FROM #{migration_info_table} WHERE #{migration_name_column} in ('add_city_state_zip_to_users', 'add_name_to_items', 'add_desc_to_items')")
    end
end
