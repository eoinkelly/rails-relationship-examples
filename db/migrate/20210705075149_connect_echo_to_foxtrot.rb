class ConnectEchoToFoxtrot < ActiveRecord::Migration[6.1]
  def change
    # The code below does the following:
    #
    # * Create echo.foxtrot_id with type `bigint` (the default type so we don't
    #   have to specify it)
    # * Allow 'echos.foxtrot_id' to be NULL. This is what creates the `0..` bit of the relationship
    # * Create a non-unique index on 'echos.foxtrot_id' for performance reasons
    # * Create a foreign key constraint on 'echos.foxtrot_id' to reference 'foxtrots.id'.
    add_belongs_to :echos, :foxtrot, foreign_key: true, null: true

    # Database **after** this migration has run:
    #
    # relationship_examples_development=# \d echos
    #     Table "public.echos"
    # Column   |              Type              | Collation | Nullable |              Default
    # ------------+--------------------------------+-----------+----------+-----------------------------------
    # id         | bigint                         |           | not null | nextval('echos_id_seq'::regclass)
    # created_at | timestamp(6) without time zone |           | not null |
    # updated_at | timestamp(6) without time zone |           | not null |
    # foxtrot_id | bigint                         |           |          |
    # Indexes:
    # "echos_pkey" PRIMARY KEY, btree (id)
    # "index_echos_on_foxtrot_id" btree (foxtrot_id)
    # Foreign-key constraints:
    # "fk_rails_a66a8fa6b4" FOREIGN KEY (foxtrot_id) REFERENCES foxtrots(id)

    # relationship_examples_development=# \d foxtrots
    #     Table "public.foxtrots"
    # Column   |              Type              | Collation | Nullable |               Default
    # ------------+--------------------------------+-----------+----------+--------------------------------------
    # id         | bigint                         |           | not null | nextval('foxtrots_id_seq'::regclass)
    # created_at | timestamp(6) without time zone |           | not null |
    # updated_at | timestamp(6) without time zone |           | not null |
    # Indexes:
    # "foxtrots_pkey" PRIMARY KEY, btree (id)
    # Referenced by:
    # TABLE "echos" CONSTRAINT "fk_rails_a66a8fa6b4" FOREIGN KEY (foxtrot_id) REFERENCES foxtrots(id)
  end
end
