Sequel.migration do
  up do
    alter_table(:users) do
      add_column :password_salt, String
      add_column :password_hash, String
    end
  end

  down do
    alter_table(:users) do
      drop_column :password_salt, String
      drop_column :password_hash, String
    end
  end
end
