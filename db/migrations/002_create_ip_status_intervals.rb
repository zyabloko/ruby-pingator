Sequel.migration do
  change do
    create_table(:ip_status_intervals) do
      primary_key :id
      foreign_key :ip_id, :ips, null: false
      DateTime :enabled_at, null: false
      DateTime :disabled_at
      DateTime :created_at, null: false

      index :ip_id
      index %i[ip_id enabled_at]
    end
  end
end
