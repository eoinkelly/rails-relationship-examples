# Modelling relationships between database entities

**This is all still WIP**

This repo is my attempt to clarify some best practices for myself around:

1. Clear thinking and clear communicating around data modelling
2. Implementing those models in Rails in the best way possible

## Clear thinking and communicating

We often have reason to draw and discuss database schemas on whiteboards etc.

* Common terms in discussion
    * "has many"
    * "has one"
* Common terms in drawing
    * (arrow with filled in head)
    * line with 1 or * at either end
    * line with nothing at one end and * at the other

but these are very ambiguous.

Imagine you have a diagram with _posts_ and _authors_ then move to something more absract like _A_ and _B_ to demonstrate how much of the clarity depends on knowledge of the domain which only *might* be there!

So "has one" can mean:

    has 0 or 1
    has exactly 1

and "has many" can mean:

    has 0 to many
    has 1 to many


We need to abandon `*` to mean "many" - it is ambiguous. `*` in reg exps
means 0-many but it's not clear in data modelling whether it also means 1-many.

### A better way: define a relationship pair

* a relationship always has a direction
* relationships always appear in pairs
  * every relationship has an "inverse relationship" which goes in the opposite direction

Instead of saying _"What is the relationship between Author and Post?_ we say _"There are a pair of relationships between Author and Post. What are they?"_

When we draw how entities are connected we know we are actually drawing **a pair** of relationships.

Draw the relationship so that the relationship label describes the relationship that the distant has with the near

In my (crude) diagrams below, you should read

    [A]{r1}----------------{r2}[B]

as

    {distant-entity} has {relationship} {close-entity}
    A has r2 B
    B has r1 A

### How many possible kinds of relationship?

Consider a single directed relationship between a and b. There are 4 possible relationships:

1. a has at most one b (0..1)
1. a has exactly on b (1)
1. a has at least one b (1..N)
1. a has 0 to many b (0..N)

There are 4 cases. There are also 4 cases in the reverse direction. This means
there are  16 possible kinds of bi-directional relationship.

These are the 16 possible bidirectional relationships:

    1.  [A]{0..1}------{0..1}[B]
    2.  [A]{1}---------{0..1}[B]
    3.  [A]{1..N}------{0..1}[B]
    4.  [A]{0..N}------{0..1}[B]
    5.  [A]{0..1}---------{1}[B] (flip of 2.)
    6.  [A]{1}------------{1}[B]
    7.  [A]{1..N}---------{1}[B]
    8.  [A]{0..N}---------{1}[B]
    9.  [A]{0..1}------{1..N}[B] (flip of 3.)
    10. [A]{1}---------{1..N}[B] (flip of 7.)
    11. [A]{1..N}------{1..N}[B]
    12. [A]{0..N}------{1..N}[B]
    13. [A]{0..1}------{0..N}[B] (flip of 4.)
    14. [A]{1}---------{0..N}[B] (flip of 8.)
    15. [A]{1..N}------{0..N}[B] (flip of 12.)
    16. [A]{0..N}------{0..N}[B]

Of the 16 possible combinations, there are only 10 unique combinations. We don't
count a bidirectional that is just the reverse direction of some other
bidirectional as being a unique kind of bidirectional

These are the 10 unique kinds of bidirectional relationship possible:

    1.  [A]{0..1}------{0..1}[B]
    2.  [A]{1}---------{0..1}[B]
    3.  [A]{1..N}------{0..1}[B]
    4.  [A]{0..N}------{0..1}[B]
    5.  [A]{1}------------{1}[B]
    6.  [A]{1..N}---------{1}[B]
    7.  [A]{0..N}---------{1}[B]
    8.  [A]{1..N}------{1..N}[B]
    9.  [A]{0..N}------{1..N}[B]
    10. [A]{0..N}------{0..N}[B]


## Modelling the 10 kinds of relationship in Rails

1.  `{0..1} to {0..1}`
    * default for `has_one`, `belongs_to`
2.  `{1} to {0..1}`
3.  `{1..N} to {0..1}`
4.  `{0..N} to {0..1}`
       * default for `has_many`, `belongs_to`
5.  `{1} to {1}`
6.  `{1..N} to {1}`
7.  `{0..N} to {1}`
8.  `{1..N} to {1..N}`
9.  `{0..N} to {1..N}`
10. `{0..N} to {0..N}`
    * default for `has_and_belongs_to_many`

Rails implements relationships with a mixture of the following tools:

* Relationship macros e.g. `belongs_to`, `has_one` etc. and the options you pass to them
* Model validations
* Database constraints created in migrations

We should think of rails validations as "advisory" rather than "enforcing" because they can be skipped. Therefore the best outcome for implementing a relationship will use **both** Rails validations **and** Database constraints.

### 1. {0..1} to {0..1}

Summary of changes by layer:

* Relationship macro layer
    * Explicitly choose a `dependent` option based on the behaviour you want in your app
* Validation layer
    * Since both sides of the relationship can be 0 there are no validations required
* Migration layer
    * Set `foreign_key: true` because it's not set by default

Example:

```ruby
# app/models/captain.rb
class Captain < ApplicationRecord
  belongs_to :starship,
    # Setting inverse_of is generally a good practice
    inverse_of: :captain,
    # Rails by default will fail the validation of a belongs_to if it's
    # association is not present so `optional: true` is required to create a
    # 0..1 relationship.
    optional: true,

    # TODO: choose the most appropriate value for `dependent` option
    dependent: nil # nil(default)|destroy|destroy_async|delete|nullify|restrict_with_exception|restrict_with_error
end

# app/models/starship.rb
class Starship < ApplicationRecord
  has_one :captain,
    # Setting inverse_of is generally a good practice
    inverse_of: :starship,
    # TODO: choose the most appropriate value for `dependent` option
    dependent: nil # nil(default)|destroy|destroy_async|delete|nullify|restrict_with_exception|restrict_with_error
end

# db/migrate/20210702203400_create_relationship_between_captain_and_starship.rb
class CreateRelationshipBetweenCaptainsAndStarship < ActiveRecord::Migration[6.0]
  def change
    add_reference :captains, :starship, foreign_key: true
    # the line above does the following:
    #
    # * captains.starship_id with type bigint (the default type so we don't have to specify it)
    # * Allows captains.starship_id to be NULL (we need this because the relationship is optional)
    # * creates an index on captains.starship_id but it does not enforce uniqueness i.e. index is for performance
    # * create a foreign key constraint on captains.starship_id to reference starships.id. This is not the default but should be i think

    # Before:
    # trek_development=# \d captains
    #                                           Table "public.captains"
    #    Column   |              Type              | Collation | Nullable |               Default
    #  to + to + to + to + to
    #  id         | bigint                         |           | not null | nextval('captains_id_seq'::regclass)
    #  name       | character varying              |           |          |
    #  created_at | timestamp(6) without time zone |           | not null |
    #  updated_at | timestamp(6) without time zone |           | not null |
    # Indexes:
    #     "captains_pkey" PRIMARY KEY, btree (id)
    #
    # After:
    # trek_development=# \d captains
    #                                           Table "public.captains"
    #    Column    |              Type              | Collation | Nullable |               Default
    #  to + to + to + to + to
    #  id          | bigint                         |           | not null | nextval('captains_id_seq'::regclass)
    #  name        | character varying              |           |          |
    #  created_at  | timestamp(6) without time zone |           | not null |
    #  updated_at  | timestamp(6) without time zone |           | not null |
    #  starship_id | bigint                         |           |          |
    # Indexes:
    #     "captains_pkey" PRIMARY KEY, btree (id)
    #     "index_captains_on_starship_id" btree (starship_id)
    # Foreign to key constraints:
    #     "fk_rails_1b9763e7e6" FOREIGN KEY (starship_id) REFERENCES starships(id)
  end
end
```

### 2. {1} to {0..1}

This is much easier and more effective to make the `belongs_to` side have
exactly one `has_one` side. Doing it the other way around is possible but less
effective (see below)
#### Making the entity with belongs_to have exactly one of the has_one entity

Summary of changes by layer:

* Relationship macro layer
    * don't set `optional: true` on the belongs_to side  to  we want to validate the association
* Validation layer
    * No code required
* Migration layer
    * Set `foreign_key: true` because it's not set by default
    * set `null: false` to enforce that the belongs_to side must have a relationship

Example:

```ruby
# app/models/captain.rb
class Captain < ApplicationRecord
  belongs_to :starship,
    inverse_of: :captain,
    optional: false, # is false by default but explicitly setting it anyway
    dependent: nil # nil(default)|destroy|destroy_async|delete|nullify|restrict_with_exception|restrict_with_error
end

# app/models/starship.rb
class Starship < ApplicationRecord
  has_one :captain,
    inverse_of: :starship,
    dependent: nil # nil(default)|destroy|destroy_async|delete|nullify|restrict_with_exception|restrict_with_error
end

# db/migrate/20210702203400_create_relationship_between_captain_and_starship.rb
class CreateRelationshipBetweenCaptainsAndStarship < ActiveRecord::Migration[6.0]
  def change
    add_reference :captains, :starship, foreign_key: true, null: false
    # the line above does the following:
    #
    # * captains.starship_id with type bigint (the default type so we don't have to specify it)
    # * Create a constraint to prevent captains.starship_id from being NULL (we need this)
    # * creates an index on captains.starship_id but it does not enforce uniqueness i.e. index is for performance
    # * create a foreign key constraint on captains.starship_id to reference starships.id.
  end
end
```

Pros/cons

* ++ Sugared by the Rails layers
* ++ Enforced at the SQL layer

#### Making the entity with has_one have exactly one of the belongs_to entity

This is more fiddly and less effective so avoid it if you can

* Relationship macro layer
    * set required: true option on has_one
* Validation layer
* Migration layer
    * we can't enforce it in sql without doing something exotic
    * "before you save record in B, check that there is a record in A which references it"
        * chicken & egg problem, could work around with deferred constraints I guess but big faff
* CONCLUSION: you can do it at the Rails layer but not at the DB layer so it's not ideal

Example:

```ruby
# app/models/captain.rb
class Captain < ApplicationRecord
  belongs_to :starship,
    inverse_of: :captain,
    optional: true, # needed
    dependent: nil # nil(default)|destroy|destroy_async|delete|nullify|restrict_with_exception|restrict_with_error
end

# app/models/starship.rb
class Starship < ApplicationRecord
  has_one :captain,
    inverse_of: :starship,
    required: true, # needed to make
    dependent: nil # nil(default)|destroy|destroy_async|delete|nullify|restrict_with_exception|restrict_with_error
end

# db/migrate/20210702203400_create_relationship_between_captain_and_starship.rb
class CreateRelationshipBetweenCaptainsAndStarship < ActiveRecord::Migration[6.0]
  def change
    add_reference :captains, :starship, foreign_key: true, null: true
    # the line above does the following:
    #
    # * captains.starship_id with type bigint (the default type so we don't have to specify it)
    # * Allow captains.starship_id to be NULL
    # * creates an index on captains.starship_id but it does not enforce uniqueness i.e. index is for performance
    # * create a foreign key constraint on captains.starship_id to reference starships.id.
  end
end
```

Pros/cons

* ++ Implemented by the Rails layers (I think)
*  to  Not enforced at the SQL layer at all.

### 3. {1..N} to {0..1}

Summary of changes by layer:

* Relationship macro layer
* Validation layer
* Migration layer

Aside: `belongs_to optional: true` in the model and `null: true` in the migration go together

    Rails has no `required: true` option for has_many

Example:

```ruby
# app/models/captain.rb
class Captain < ApplicationRecord
  belongs_to :starship,
    inverse_of: :captains,
    optional: true, # needed
    dependent: nil # nil(default)|destroy|destroy_async|delete|nullify|restrict_with_exception|restrict_with_error
end

# app/models/starship.rb
class Starship < ApplicationRecord
  has_many :captains,
    inverse_of: :starships,
    dependent: nil # nil(default)|destroy|destroy_async|delete|nullify|restrict_with_exception|restrict_with_error

  # Use a validation to try to "enforce" that a Starship always has at least 1
  # Captain. This isn't really enforcing because there is a bunch of Rails API
  # for doing things skipping validations
  validates :captains, presence: true
end

# db/migrate/20210702203400_create_relationship_between_captain_and_starship.rb
class CreateRelationshipBetweenCaptainsAndStarship < ActiveRecord::Migration[6.0]
  def change
    add_reference :captains, :starship, foreign_key: true, null: true
    # the line above does the following:
    #
    # * captains.starship_id with type bigint (the default type so we don't have to specify it)
    # * Allows captains.starship_id to be NULL (we need this because the relationship is optional)
    # * creates an index on captains.starship_id but it does not enforce uniqueness i.e. index is for performance
    # * create a foreign key constraint on captains.starship_id to reference starships.id. This is not the default but should be i think
  end
end
```

Pros/cons

* ++ Implemented by the Rails layers
*  to  Not enforced at the SQL layer at all so if you skip validations, you can break the relationship

### 4. {0..N} to {0..1}

This is a standard Rails has_many...belongs_to

Summary of changes by layer:

* Relationship macro layer
* Validation layer
* Migration layer

Example:

```ruby
# app/models/captain.rb
class Captain < ApplicationRecord
  belongs_to :starship,
    inverse_of: :captains,
    optional: true, # needed for the 0.. bit
    dependent: nil # nil(default)|destroy|destroy_async|delete|nullify|restrict_with_exception|restrict_with_error
end

# app/models/starship.rb
class Starship < ApplicationRecord
  has_many :captains,
    inverse_of: :starships,
    dependent: nil # nil(default)|destroy|destroy_async|delete|nullify|restrict_with_exception|restrict_with_error
end

# db/migrate/20210702203400_create_relationship_between_captain_and_starship.rb
class CreateRelationshipBetweenCaptainsAndStarship < ActiveRecord::Migration[6.0]
  def change
    add_reference :captains, :starship, foreign_key: true, null: true
    # the line above does the following:
    #
    # * captains.starship_id with type bigint (the default type so we don't have to specify it)
    # * Allows captains.starship_id to be NULL (we need this because the relationship is optional)
    # * creates an index on captains.starship_id but it does not enforce uniqueness i.e. index is for performance
    # * create a foreign key constraint on captains.starship_id to reference starships.id. This is not the default but should be i think
  end
end
```

Pros/cons

* ++ Rails + SQL implements this just fine
* ++ Implemented by the Rails layers, enforced (not that there is much to enforce) at the SQL layer

### 5. {1} to {1}

Rarely used
Requires you to
    create both records at the same time (otherwise you have a chicken & egg problem)
    delete both records at same time
    updates are normal
You could do it with deferred constraints and/or triggers

rails layer
    aaa
        has_one :bbb
    bbb
        belongs_to :aaa
db layer
    on the bbb.aaa_id col (the foreign key col)
        make sure foreign key constraint set (should always be set)
        set NOT NULL (this ensures that bbb alwasy has one aaa)
        set unique index (this forces each bbb to have a different aaa)
            not strictly part of a 1 to 1 or is it?
    caveats
        how can i force aaa to always have a bbb at the DB level?
            I don't think it can be done at the DB level without something like a trigger?

### 6. {1..N} to {1}
### 7. {0..N} to {1}
### 8. {1..N} to {1..N}
### 9. {0..N} to {1..N}
### 10. {0..N} to {0..N}

#### Using habtm

    This is WIP

Summary of changes by layer:

* Relationship macro layer
* Validation layer
* Migration layer

    NOTE: habtm has no dependent option

Pros/cons

* -- You cannot set a `dependent` attribute on the HABTM macro
    * ??? what are implications of this?
* -- Possible loss of future flexibility
    * The migration doesn't create a unique id column for the join table so you'll need to add that in (and retrofit data values into it) if you later want to convert it to a `has_many(through: ...)`
    * You might actually want to turn the join into a real model in future which would be annoying work

Example:

```ruby
# app/models/captain.rb
class Captain < ApplicationRecord
  has_and_belongs_to_many :starships,
    inverse_of: :captains,
end

# app/models/starship.rb
class Starship < ApplicationRecord
  has_and_belongs_to_many :captains,
    inverse_of: :starships,
end

# app/models/captain_starship.rb
class CaptainStarship < ApplicationRecord
  has_and_belongs_to_many :captains,
    inverse_of: :starships,
end

# db/migrate/20210702203400_create_relationship_between_captain_and_starship.rb
class CreateRelationshipBetweenCaptainsAndStarship < ActiveRecord::Migration[6.0]
  def change
    create_join_table(:captains, :starships, column_options: { foreign_key: true, null: false }) do |t|
      t.index [:captain_id, :starship_id]
      t.index [:starship_id, :captain_id]
    end
    # After:
    # trek_development=# \d captains_starships
    #            Table "public.captains_starships"
    #    Column    |  Type  | Collation | Nullable | Default
    # -------------+--------+-----------+----------+---------
    #  captain_id  | bigint |           | not null |
    #  starship_id | bigint |           | not null |
    # Indexes:
    #     "index_captains_starships_on_captain_id_and_starship_id" btree (captain_id, starship_id)
    #     "index_captains_starships_on_starship_id_and_captain_id" btree (starship_id, captain_id)
    # Foreign-key constraints:
    #     "fk_rails_0925827edf" FOREIGN KEY (starship_id) REFERENCES starships(id)
    #     "fk_rails_764b7a3fdf" FOREIGN KEY (captain_id) REFERENCES captains(id)

  end
end
```

#### Using has_many through:

    This is WIP

Summary of changes by layer:

* Relationship macro layer
* Validation layer
* Migration layer

Example:

```ruby
# app/models/captain.rb
class Captain < ApplicationRecord
  has_many :postings, inverse_of: :captain
  has_many :starships, through: :postings
  # TODO: how to set inverse of?
end

# app/models/starship.rb
class Starship < ApplicationRecord
  has_many :postings, inverse_of: :captain
  has_many :starships, through: :posting
  # TODO: how to set inverse of?
end

# app/models/posting.rb
class Posting < ApplicationRecord
  belongs_to :captain, inverse_of: :postings
  belongs_to :starship, inverse_of: :postings
end

# db/migrate/20210702203400_create_relationship_between_captain_and_starship.rb
class CreateRelationshipBetweenCaptainsAndStarship < ActiveRecord::Migration[6.0]
  def change
    create_table :postings do |t|
      # use the singular name not the plural table name as first arg to belongs_To
      t.belongs_to :captain, foreign_key: true, null: false
      t.belongs_to :starship, foreign_key: true, null: false
      t.index [:captain_id, :starship_id]
      t.index [:starship_id, :captain_id]
    end
  end
end
```

Pros/cons

* -- bit more wordy than HABTM
* ++ you can specify a dependent option
* ++ more flexible for the future if you want to grow the jion model into a real model



## Sources

* "All for One, One for all" paper by C.J. Date http://www.dcs.warwick.ac.uk/~hugh/TTM/AllforOne.pdf
