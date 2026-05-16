Sequel.migration do
  change do
    create_table(:ips) do
      primary_key :id
      inet :ip, null: false
      boolean :enabled, default: true, null: false
      DateTime :created_at, null: false
      DateTime :updated_at, null: false

      index :ip, unique: true
    end
  end
end
