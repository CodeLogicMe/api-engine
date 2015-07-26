class PortFromMongo < ActiveRecord::Migration
  def change
    enable_extension 'hstore'

    create_table :clients do |t|
      t.string :email, null: false
      t.string :password_hash, null: false
      t.timestamps
    end
    add_index :clients, :email, unique: true

    create_table :apis do |t|
      t.references :client, null: false
      t.string :name, null: false
      t.string :system_name, null: false
      t.string :public_key
      t.timestamps
    end
    add_index :apis, :system_name, unique: true
    add_index :apis, :public_key, unique: true

    create_table :private_keys do |t|
      t.references :api, null: false
      t.string :secret, null: false
      t.datetime :created_at, null: false
    end
    add_index :private_keys, :secret, unique: true

    create_table :collections do |t|
      t.references :api, null: false
      t.string :name, null: false
      t.string :system_name, null: false
      t.timestamps
    end
    add_index :collections, :name
    add_index :collections, :system_name

    create_table :fields do |t|
      t.references :collection, null: false
      t.string :name, null: false
      t.string :type, null: false
      t.text :validations, array: true, default: []
    end

    create_table :records do |t|
      t.references :api, null: false
      t.references :collection, null: false
      t.hstore :data
      t.timestamps
    end
    add_index :records, [:api_id, :collection_id]
    add_index :records, :data, using: :gin

    create_table :smart_requests do |t|
      t.integer :status, null: false
      t.inet :ip, null: false
      t.hstore :geolocation
      t.string :browser
      t.string :platform
      t.datetime :started_at, null: false
      t.datetime :ended_at, null: false
      t.decimal :duration, precision: 3
    end

    create_table :tiers do |t|
      t.string :name, null: false
      t.string :system_name, null: false
      t.integer :quota, null: false
      t.decimal :price, precision: 15, scale: 2, null: false
    end

    create_table :tier_usages do |t|
      t.references :tier, null: false
      t.references :api, null: false
      t.datetime :created_at, null: false
      t.datetime :deactivated_at
    end
  end
end
