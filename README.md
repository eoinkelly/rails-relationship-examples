# Modelling relationships between database entities

**This is all still WIP**

This repo is my attempt to clarify some best practices for myself around:

1. Clear thinking and clear communicating around data modelling
2. Implementing those models in Rails in the best way possible

## Clear thinking and communicating

> The Biggest Problem in Communication Is the Illusion That It Has Taken Place

We often discuss database schemas, draw them on on whiteboards etc.

Common terms in discussion I have heard and used are  _"has many"_, _"has one"_ etc.
In drawings we often use

* An warrow with filled in head to indicate "many"
* line with `1` or `*` at either end
* line with nothing at one end and `*` at the other

I think should avoid these phrases and notations because they are ambigious. They are ambigious because:

1. they don't tell you what should happen in the "zero case" e.g. does _"A has one B"_ mean "A has exactly one B" or _"A usually has one B but might have none"_.
1. Coming from a developer background, we are a bit primed to think of `*` as meaning _0 to many_ because that is how it reads in a regular expression but not everybody involved in data modelling is a developer. It seems common in data modelling for it to mean
 _"one to many"_.

Fuzzy terms can be _ok_ if we already have knowledge of the domain e.g. if the diagram has _posts_ and _authors_ then we already know some things about how that should behave in the real world.

However we aren't always working with a domain that we understand. If, for example, the diagram is about something more abstract like _A_ and _B_ then we have to rely solely on what's in the diagram rather than expertise we already have on the domain.

### Confusion around what "relationship" actually means

When we talk about "relationships" in data modelling, we usually refeerring to a pair of relationships

Every relationship has an "inverse relationship" which goes in the opposite direction.
This "relationship pair" is often called a _bidirectional relationship_. Don't let the singular fool you, a bidirectional relationship is actually two single direction relationships.

Relationships are _"bidirectional"_.
Our language and diagrams should reflect this.

Relationships always appear in pairs. We call the pair a bidirectional relationship.

Instead of saying:

> What is the relationship between Author and Post?

we should probably say something like:

> There are a pair of relationships between Author and Post. What are they?

When we draw how entities are connected we know we are actually drawing **a pair** of relationships.

My (crude) diagrams below attempt to capture this. You can read them as follows:

    [A]{r1}----------------{r2}[B]

as

    {distant-entity} has {relationship} {close-entity}
    A has r2 B
    B has r1 A


    TODO: research what UML says here and decide whether it's more useful than my informal stuff

### How many possible kinds of relationship?

Consider a single directed relationship from entity A to entity B. There are 4 possible kinds of single direction relationship:

1. A has at most one B (notated as `0..1`)
1. A has exactly one B (notated as `1`)
1. A has at least one B (notated as `1..N`)
1. A has 0 to many B (notated as `0..N`)

There are 4 cases. There are also 4 cases in the reverse direction from B to A. This means there are 16 possible kinds of bidirectional relationship.

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

Of the 16 possible combinations, there are only 10 unique combinations if we remove relationships which differ only in their direction.

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

So, whether we knew it before now or not, these 10 relationships are the toolbox we use to create data models. There are only 10 possible kinds of bidirectional relationship so all the schemas we discuss, diagram and build will be some combination of these.

Next we should look at how to implement these in Rails.

## Modelling the 10 kinds of relationship in Rails

1.  `{0..1} to {0..1}`
    * default for `has_one`, `belongs_to` combination
2.  `{1} to {0..1}`
3.  `{1..N} to {0..1}`
4.  `{0..N} to {0..1}`
       * default for `has_many`, `belongs_to` combination
5.  `{1} to {1}`
6.  `{1..N} to {1}`
7.  `{0..N} to {1}`
8.  `{1..N} to {1..N}`
9.  `{0..N} to {1..N}`
10. `{0..N} to {0..N}`
    * default for `has_and_belongs_to_many` or `has_many(through:...)` pair

Notice that the relationships Rails creates include the zero case by default i.e. you have to do a bit extra to prevent a relationship from being empty.

Rails implements relationships with a mixture of the following tools:

1. Relationship macros e.g. `belongs_to`, `has_one` etc. and the options you pass to them
1. Model validations
1. Database constraints created in migrations

We should think of rails validations as "advisory" rather than "enforcing" because they can be skipped.

Therefore the best outcome for implementing a relationship will use **both** Rails validations **and** Database constraints. This isn't always feasible to achieve, usually for performance reasons or because the implementation would be very fiddly.

### 1. {0..1} to {0..1}

    [Alfa]{0..1} ---- {0..1}[Bravo]

Rails implements this using the `belongs_to` and `has_one` macros. We need to decide which model should get the `belongs_to`.

It doesn't really matter where we put the `belongs_to` to implement this relationship (it will matter for some of the other relationships) so in our example we arbitrarily put `belongs_to` in `Alfa` and `has_one` in `Bravo`.

Things to watch out for:

* Rails does not create foreign key constraints by default in migrations. These constraints are very important for maintaining data integrity so we need to add the `foreign_key: true` option in the migration.
* Rails will validate a `belongs_to` relationship by default but not a `has_one` so we need `belongs_to(..., optional: true)`

Annotated Code changes:

* Rails layer (sugar and advisory constraints)
    * [app/models/alfa.rb](app/models/alfa.rb)
    * [app/models/bravo.rb](app/models/bravo.rb)
* Database layer (enforcing constraints)
    * [db/migrate/20210704022223_connect_alfa_and_bravo.rb](db/migrate/20210704022223_connect_alfa_and_bravo.rb)

Rate the outcome:

| Q                                                              | A   |
| -------------------------------------------------------------- | --- |
| Can this relationship be broken by skipping Rails validations? | No  |


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
