Sequel.migration do
  change do
    create_table(:ping_results) do
      primary_key :id
      foreign_key :ip_id, :ips, null: false
      DateTime :pinged_at, null: false
      BigDecimal :rtt, size: [10, 3]
      boolean :success, null: false, default: false
      DateTime :created_at, null: false

      index :ip_id
      index %i[ip_id pinged_at]
    end
  end
end
