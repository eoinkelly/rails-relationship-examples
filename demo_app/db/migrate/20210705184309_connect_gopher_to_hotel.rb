class ConnectGopherToHotel < ActiveRecord::Migration[6.1]
  def change
    # The code below does the following:
    #
    # * Create gophers.hotel_id with type `bigint` (the default type so we don't
    #   have to specify it)
    # * Allow 'gophers.hotel_id' to be NULL. This is what creates the `0..` bit of the relationship
    # * Create a non-unique index on 'gophers.hotel_id' for performance reasons
    # * Create a foreign key constraint on 'gophers.hotel_id' to reference 'hotels.id'.
    add_belongs_to :gophers, :hotel, foreign_key: { on_delete: :nullify }, null: true

    # Database **after** this migration has run:
    #
    # relationship_examples_development=# \d gophers
    #     Table "public.gophers"
    # Column   |              Type              | Collation | Nullable |              Default
    # ------------+--------------------------------+-----------+----------+------------------------------------
    # id         | bigint                         |           | not null | nextval('gophers_id_seq'::regclass)
    # created_at | timestamp(6) without time zone |           | not null |
    # updated_at | timestamp(6) without time zone |           | not null |
    # hotel_id   | bigint                         |           |          |
    # Indexes:
    # "gophers_pkey" PRIMARY KEY, btree (id)
    # "index_gophers_on_hotel_id" btree (hotel_id)
    # Foreign-key constraints:
    # "fk_rails_eae96cbc5f" FOREIGN KEY (hotel_id) REFERENCES hotels(id) ON DELETE SET NULL

    # relationship_examples_development=# \d hotels
    #     Table "public.hotels"
    # Column   |              Type              | Collation | Nullable |              Default
    # ------------+--------------------------------+-----------+----------+------------------------------------
    # id         | bigint                         |           | not null | nextval('hotels_id_seq'::regclass)
    # created_at | timestamp(6) without time zone |           | not null |
    # updated_at | timestamp(6) without time zone |           | not null |
    # Indexes:
    # "hotels_pkey" PRIMARY KEY, btree (id)
    # Referenced by:
    # TABLE "gophers" CONSTRAINT "fk_rails_eae96cbc5f" FOREIGN KEY (hotel_id) REFERENCES hotels(id) ON DELETE SET NULL
  end
end
