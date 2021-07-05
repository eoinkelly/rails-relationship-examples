class ConnectCharlieAndDeltum < ActiveRecord::Migration[6.1]
  def change
    # The code below does the following:
    #
    # * Create charlie.deltum_id with type `bigint` (the default type so we don't
    #   have to specify it)
    # * Prevent charlies.deltum_id from being NULL. This is what enforces the
    #   "exactly 1" nature of the relationship.
    # * Create a non-unique index on 'charlies.deltum_id' for performance reasons
    # * Create a foreign key constraint on 'charlies.deltum_id' to reference 'deltums.id'.
    add_belongs_to :charlies, :deltum, foreign_key: true, null: false

    # Database **after** this migration has run:
    #
    # relationship_examples_development=# \d delta
    #     Table "public.delta"
    # Column   |              Type              | Collation | Nullable |              Default
    # ------------+--------------------------------+-----------+----------+-----------------------------------
    # id         | bigint                         |           | not null | nextval('delta_id_seq'::regclass)
    # created_at | timestamp(6) without time zone |           | not null |
    # updated_at | timestamp(6) without time zone |           | not null |
    # Indexes:
    # "delta_pkey" PRIMARY KEY, btree (id)
    # Referenced by:
    # TABLE "charlies" CONSTRAINT "fk_rails_2763c9d366" FOREIGN KEY (deltum_id) REFERENCES delta(id)

    # relationship_examples_development=# \d charlies
    #                                           Table "public.charlies"
    #    Column   |              Type              | Collation | Nullable |               Default
    # ------------+--------------------------------+-----------+----------+--------------------------------------
    #  id         | bigint                         |           | not null | nextval('charlies_id_seq'::regclass)
    #  created_at | timestamp(6) without time zone |           | not null |
    #  updated_at | timestamp(6) without time zone |           | not null |
    #  deltum_id  | bigint                         |           | not null |
    # Indexes:
    #     "charlies_pkey" PRIMARY KEY, btree (id)
    #     "index_charlies_on_deltum_id" btree (deltum_id)
    # Foreign-key constraints:
    #     "fk_rails_2763c9d366" FOREIGN KEY (deltum_id) REFERENCES delta(id)
  end
end
