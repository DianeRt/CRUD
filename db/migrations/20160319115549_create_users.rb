Sequel.migration do
  up do
    create_table?(:users) do
      primary_key :id
      Boolean :admin
      String :fname
      String :lname
      String :email
      String :username
    end 
  end

  down do
    drop_table(:users)
  end
end
