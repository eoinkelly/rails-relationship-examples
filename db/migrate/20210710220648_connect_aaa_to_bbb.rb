# This is an attempt to implement a {0..1} <--> {1..N} using a join table
# I'm curious about whether it gives a better outcome

class ConnectAaaToBbb < ActiveRecord::Migration[6.1]
  def change
    # create a join table between them
    # create a foreign key constraint between the main tables and the join table
    # ^^^ so far, we have a standard 0..N to 0..N
    create_join_table(:aaas, :bbbs, column_options: { foreign_key: true, null: false }) do |t|
      # t.index [:captain_id, :starship_id]
      # t.index [:starship_id, :captain_id]
    end

    # ^^^ so far, we have a standard A 0..N to 0..N B
    # I want:
    # Aaa has 0..1 Bbb
    # Bbb has 1..N Aaa

    # so need to limit each Aaa to having only one Bbb
    # add a unique constraint on the aaa_id col of the join model
    # so that each aaa row can only appear once in the table


    # I want each bbb row to always have at least one entry in the join table
    # so i need to reject any create to bbbs which doesn't also add it ot the join table
    # and reject any removal of a value from the bbb_id col in the join table unless the corresponding bbb row is being removed too
    # to do this at the SQL layer would (I think) require having
    # 1. a bbbs.aaa_id column  which is NOT NULL
    # 2. a join table between aaas and bbbs which also contains an aaa_id column
    # The join table is used for joining. The duplicate col (bbbs.aaa_id) is used to ensure there is always one
    # For this to work, the ORM (or wahtever code you use to manage the relationship) needs to support it
    # Rails does not.


    # so in SQL
    # is it true to say that
    # the only way to require the existance of a relationship is to have the id be part of a row in one of the entities
    # because then NOT NULL says that you can't have the row without having the relationship
    # but it's much harder to enforce that you can't have a row in table A unless a reference in B exists to it

    # in SQL
    # maintaining integrity and deduplication are sometimes at odds

    # if you duplicate the

    # now add constraints to make it a 1 to N in just one direction
    # maybe that will work?
  end
end
