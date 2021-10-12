class ConnectAlfaAndBravo < ActiveRecord::Migration[6.1]
  def change
    # The code below does the following:
    #
    # * Create alfa.bravo_id with type `bigint` (the default type so we don't
    #   have to specify it)
    # * Allow alfas.bravo_id to be NULL (we need this because the relationship
    #   is optional). This is the default but we do it explicitly here for
    #   clarity.
    # * Create a non-unique index on 'alfas.bravo_id' for performance reasons
    # * Create a foreign key constraint on 'alfas.bravo_id' to reference
    #  'bravos.id'. Configure the foreign key constraint so that if a row from
    #  'bravos' is deleted, then any rows in `alfas` which reference that row
    #  will have their `alfas.bravo_id` set to `null`
    add_belongs_to :alfas, :bravo, foreign_key: { on_delete: :nullify }, null: true

    # Database **after** this migration has run:
    #
    # relationship_examples_development=# \d alfas
    #     Table "public.alfas"
    # Column   |              Type              | Collation | Nullable |              Default
    # ------------+--------------------------------+-----------+----------+-----------------------------------
    # id         | bigint                         |           | not null | nextval('alfas_id_seq'::regclass)
    # created_at | timestamp(6) without time zone |           | not null |
    # updated_at | timestamp(6) without time zone |           | not null |
    # bravo_id   | bigint                         |           |          |
    # Indexes:
    # "alfas_pkey" PRIMARY KEY, btree (id)
    # "index_alfas_on_bravo_id" btree (bravo_id)
    # Foreign-key constraints:
    # "fk_rails_695e7121a5" FOREIGN KEY (bravo_id) REFERENCES bravos(id) ON DELETE SET NULL

    # relationship_examples_development=# \d bravos
    #     Table "public.bravos"
    # Column   |              Type              | Collation | Nullable |              Default
    # ------------+--------------------------------+-----------+----------+------------------------------------
    # id         | bigint                         |           | not null | nextval('bravos_id_seq'::regclass)
    # created_at | timestamp(6) without time zone |           | not null |
    # updated_at | timestamp(6) without time zone |           | not null |
    # Indexes:
    # "bravos_pkey" PRIMARY KEY, btree (id)
    # Referenced by:
    # TABLE "alfas" CONSTRAINT "fk_rails_695e7121a5" FOREIGN KEY (bravo_id) REFERENCES bravos(id) ON DELETE SET NULL
  end
end
