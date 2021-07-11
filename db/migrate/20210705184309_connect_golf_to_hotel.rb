class ConnectGolfToHotel < ActiveRecord::Migration[6.1]
  def change
    # The code below does the following:
    #
    # * Create golfs.hotel_id with type `bigint` (the default type so we don't
    #   have to specify it)
    # * Allow 'golfs.hotel_id' to be NULL. This is what creates the `0..` bit of the relationship
    # * Create a non-unique index on 'golfs.hotel_id' for performance reasons
    # * Create a foreign key constraint on 'golfs.hotel_id' to reference 'hotels.id'.
    add_belongs_to :golves, :hotel, foreign_key: { on_delete: :nullify }, null: true

    # Database **after** this migration has run:
    #
    # relationship_examples_development=# \d golves
    #     Table "public.golves"
    # Column   |              Type              | Collation | Nullable |              Default
    # ------------+--------------------------------+-----------+----------+------------------------------------
    # id         | bigint                         |           | not null | nextval('golves_id_seq'::regclass)
    # created_at | timestamp(6) without time zone |           | not null |
    # updated_at | timestamp(6) without time zone |           | not null |
    # hotel_id   | bigint                         |           |          |
    # Indexes:
    # "golves_pkey" PRIMARY KEY, btree (id)
    # "index_golves_on_hotel_id" btree (hotel_id)
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
    # TABLE "golves" CONSTRAINT "fk_rails_eae96cbc5f" FOREIGN KEY (hotel_id) REFERENCES hotels(id) ON DELETE SET NULL
  end
end
