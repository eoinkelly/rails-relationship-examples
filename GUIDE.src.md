# A guide to database modelling with Rails

- [A guide to database modelling with Rails](#a-guide-to-database-modelling-with-rails)
  - [Introduction](#introduction)
  - [Part 1: Just enough data modelling to get by](#part-1-just-enough-data-modelling-to-get-by)
    - [Problem: Fuzzy language](#problem-fuzzy-language)
    - [The 4 deletion behaviours](#the-4-deletion-behaviours)
    - [Problem: Cardinality vs multiplicity](#problem-cardinality-vs-multiplicity)
      - [Multiplicity](#multiplicity)
    - [Problem: Many notations](#problem-many-notations)
    - [Relationships come in pairs](#relationships-come-in-pairs)
      - [Reading relationship pair diagrams](#reading-relationship-pair-diagrams)
    - [How many kinds of relationship exist?](#how-many-kinds-of-relationship-exist)
  - [Part 2: Overview of relationships in Rails](#part-2-overview-of-relationships-in-rails)
    - [Problem: SQL Databases have limited support for enforcing 1..N relationships](#problem-sql-databases-have-limited-support-for-enforcing-1n-relationships)
    - [Rails does not create foreign key constraints by default in migrations.](#rails-does-not-create-foreign-key-constraints-by-default-in-migrations)
    - [??? Good thing: Rails automatically adds an index to the foreign key column (WIP)](#-good-thing-rails-automatically-adds-an-index-to-the-foreign-key-column-wip)
    - [Good thing: Rails' synthetic ID columns](#good-thing-rails-synthetic-id-columns)
  - [Part 3: The 10 kinds of relationship in Rails](#part-3-the-10-kinds-of-relationship-in-rails)
    - [1. {0..1} to {0..1}](#1-01-to-01)
      - [Overview](#overview)
      - [Choose: macros and options](#choose-macros-and-options)
      - [Choose: which side gets each macro](#choose-which-side-gets-each-macro)
      - [Choose: deletion behaviour](#choose-deletion-behaviour)
      - [Implement: migration options](#implement-migration-options)
      - [Implement: Add validations and callbacks (if required)](#implement-add-validations-and-callbacks-if-required)
      - [Example code](#example-code)
      - [Implementation score card:](#implementation-score-card)
    - [2. {0..1} to {1}](#2-01-to-1)
      - [Overview](#overview-1)
      - [Choose: macros and options](#choose-macros-and-options-1)
      - [Choose: which side gets each macro](#choose-which-side-gets-each-macro-1)
      - [Choose: deletion behaviour](#choose-deletion-behaviour-1)
      - [Implement: migration options](#implement-migration-options-1)
      - [Implement: Add validations and callbacks (if required)](#implement-add-validations-and-callbacks-if-required-1)
      - [Example code](#example-code-1)
      - [Implementation score card:](#implementation-score-card-1)
    - [3. {1..N} to {0..1}](#3-1n-to-01)
      - [Overview](#overview-2)
      - [Choose: deletion behaviour](#choose-deletion-behaviour-2)
      - [Choose: macros and options](#choose-macros-and-options-2)
      - [Choose: which side gets each macro](#choose-which-side-gets-each-macro-2)
      - [Implement: migration options](#implement-migration-options-2)
      - [Implement: Add validations and callbacks (if required)](#implement-add-validations-and-callbacks-if-required-2)
      - [Example code](#example-code-2)
      - [Implementation score card:](#implementation-score-card-2)
    - [4. {0..N} to {0..1}](#4-0n-to-01)
    - [5. {1} to {1}](#5-1-to-1)
    - [6. {1..N} to {1}](#6-1n-to-1)
    - [7. {0..N} to {1}](#7-0n-to-1)
    - [8. {1..N} to {1..N}](#8-1n-to-1n)
    - [9. {0..N} to {1..N}](#9-0n-to-1n)
    - [10. {0..N} to {0..N}](#10-0n-to-0n)
      - [Using habtm](#using-habtm)
      - [Using has_many through:](#using-has_many-through)
  - [Sources](#sources)

## Introduction

I wrote this to clarify my own thinking and communication of

1. Database modelling
2. Implementing those models in Rails

I hope you find it useful.

## Part 1: Just enough data modelling to get by

### Problem: Fuzzy language

> The biggest problem in communication is the illusion that it has taken place
>
> Unknown (often attributed to George Bernard Shaw)

We often discuss database schemas, draw them on on whiteboards etc.

Common terms used are  _"has many"_, _"has one"_ etc.

In drawings we often use

* An arrow with filled in head to indicate "many"
* line with `1` or `*` at either end
* line with nothing at one end and `*` at the other

Rails vocabulary for expressing relationships includes phrases like `has_one`, `has_many` etc.

The problem with these phrases and notations because they are ambiguous. They are ambiguous because:

1. they don't tell you what should happen in the "zero case" e.g. does _"A has one B"_ mean "A has exactly one B" or _"A usually has one B but might have none"_.
1. Coming from a developer background, we are a bit primed to think of `*` as meaning _0 to many_ because that is how it reads in a regular expression. `*` means a similar but different thing in data modelling.

Fuzzy terms can be _ok_ if *everybody* involved already has good knowledge of the domain e.g. if the diagram has _posts_ and _authors_ then we already know some things about how that should behave in the real world.

However we aren't always working with a domain that we understand or with a team where everybody understands the business domain. This document will discuss entities _A_ and _B_ so we have to rely solely on what's in the diagram rather than expertise we already have on the domain.

### The 4 deletion behaviours

Database design tools and diagrams usually don't specify what should happen when a record on each side of the relationship is deleted but we still need to choose a deletion behaviour as part of our design process.

There are four deletion behaviours we choose from:

1. Refuse to delete the record and raise an exception (common)
1. Nullify the referencing column (common).
1. Take No Action (common if any side of the relationship can have 0 items i.e. `0..`).
    * We need to be careful with this one to ensure we don't leave a DB column with a reference to an ID in another table which no longer exists!
1. Automatically delete all referencing rows when a row is deleted, also known as a _Cascade delete_ (uncommon)

### Problem: Cardinality vs multiplicity

When we are modelling data, we need to describe the size of collections e.g.

* _"A must have exactly 1 B"_. Collection min=1, max=1
* _"A can have between 0 and 10 B"_. Collection min=0, max=10
* _"A can have between 0 and 1 B"_. Collection min=0, max=1

The size of a collection is called it's **cardinality**. But there's a wrinkle. Technically, the cardinality is the **actual number of elements in the collection** and **multiplicity** is the description of what the minimum and maximum size of the collection is. So the descriptions above are a list of multiplicities not cardinalities.

For example, if we have a description of a database relationship between A and B:

> _"A can have between 0 and 10 B"_

then we know the **multiplicity** (min=0, max=10) but we don't know the **cardinality** unless we actually look in the database and find out what the actual size of the collection is.

Cardinality and multiplicity mean different things but the reality is that the words are often used interchangeably. Once you know the difference you will be able to figure out which one the other person means from context. See https://martinfowler.com/bliki/MultiplicityNotCardinality.html for more info.

This document will use the term _multiplicity_ because I prefer it.

#### Multiplicity

Multiplicity is a fancy name for a way of writing the **range** of sizes that a collection can have.

Multiplicities are written using range notation:

    minimum..maximum

The special `*` symbol represents "no maximum" i.e. we don't want to set an upper bound on how many things can be in the collection.
Note that this is similar but not the same as it's meaning in regular expressions.


Some examples

| Multiplicity | Meaning                                                         |
| ------------ | --------------------------------------------------------------- |
| 0..1         | Collection can be empty or contain one thing                    |
| 0..42        | Collection can be empty or contain up to 42 things              |
| 0..*         | Collection can be empty or contain an infinite number of things |
| 1..1         | Collection must contain exactly one thing                       |
| 3..3         | Collection must contain exactly three things                    |

There are some short-cuts we can take

| Multiplicity | Meaning                                   |
| ------------ | ----------------------------------------- |
| 1..1         | Collection must contain exactly one thing |
| 1            | means the same as above                   |

| Multiplicity | Meaning                                                         |
| ------------ | --------------------------------------------------------------- |
| 0..*         | Collection can be empty or contain an infinite number of things |
| *            | means the same as above                                         |

### Problem: Many notations

There are a number of notations for drawing diagrams when we are modelling data e.g.

* [UML notation](https://www.vertabelo.com/blog/technical-articles/uml-notation)
* [Crow's Foot notation](https://www.vertabelo.com/blog/crow-s-foot-notation/)
* [Chen notation](https://www.vertabelo.com/blog/technical-articles/chen-erd-notation)
* [Barker notation](https://www.vertabelo.com/blog/technical-articles/barkers-erd-notation)
* [Arrow notation](https://www.vertabelo.com/blog/arrow-notation/)
* [IDEF1X notation](https://www.vertabelo.com/blog/technical-articles/idef1x-notation)


This document will use UML notation but it's good to be aware of the others because the person/team you are working with may have chosen one of those as their preferred style.

### Relationships come in pairs

When we talk about _"the relationship between A and B"_ in data modelling, we actually referring to **a pair of relationships**.

Every relationship has an "inverse relationship" which goes in the opposite direction. This "relationship pair" is often called a _bidirectional relationship_. Don't let the singular fool you, a bidirectional relationship is actually two single-direction relationships.

Instead of saying:

> What is the relationship between Author and Post?

we should probably say something like:

> There are a pair of relationships between Author and Post. What are they?

but we don't because we assumes that everybody understands this non-obvious thing :shrug:.

#### Reading relationship pair diagrams

We know now that when we draw how two entities are connected, we are actually drawing **a pair** of relationships.

The conventional way to draw this pair is something like:

    [A]r1________________r2[B]

which is read as:

    A has r2 to B
    B has r1 to A

These tricks can help:

* Imagine the word "has" in the middle to help you remember the order.
* In english, the details of the relationship come after the "has in the sentence e.g. _"A has r2 to B"_
* Remember you are looking at a **pair** of relationships. You read the diagram from left to right to get one part of the relationship and from right to left to get the other part.

Consider this example:

    [A]0..1________________1..*[B]

reads as

    [A]0..1_____ has ______1..*[B]

    A            has       one to many B (reading left to right)
    B            has       zero to one B (reading right to left)

### How many kinds of relationship exist?

Consider a single directed relationship from entity A to entity B. There are 4 possible kinds of single direction relationship:

1. A has at most one B (notated as `0..1`)
1. A has exactly one B (notated as `1`)
1. A has at least one B (notated as `1..N`)
1. A has 0 to many B (notated as `0..N`)

There are 4 cases. There are also 4 cases in the reverse direction from B to A. This means there are 16 possible kinds of bidirectional relationship (each single direction relationship can be paired up with one of the four inverse direction relationships so you get  4 x 4 possible combinations).

These are the 16 possible bidirectional relationships:

    1.  [A]{0..1}------{0..1}[B]
    2.  [A]{1}---------{0..1}[B]
    3.  [A]{1..N}------{0..1}[B]
    4.  [A]{0..N}------{0..1}[B]
    5.  [A]{0..1}---------{1}[B] (reverse direction of 2.)
    6.  [A]{1}------------{1}[B]
    7.  [A]{1..N}---------{1}[B]
    8.  [A]{0..N}---------{1}[B]
    9.  [A]{0..1}------{1..N}[B] (reverse direction of 3.)
    10. [A]{1}---------{1..N}[B] (reverse direction of 7.)
    11. [A]{1..N}------{1..N}[B]
    12. [A]{0..N}------{1..N}[B]
    13. [A]{0..1}------{0..N}[B] (reverse direction of 4.)
    14. [A]{1}---------{0..N}[B] (reverse direction of 8.)
    15. [A]{1..N}------{0..N}[B] (reverse direction of 12.)
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

So, whether we knew it before now or not, these 10 relationships are the toolbox we use to create data models. There are only 10 possible kinds of bidirectional relationship so all the schemas we build will be some combination of these.

Next we will look at how to implement these in Rails.


## Part 2: Overview of relationships in Rails

We know now that there are 10 possible DB relationships that we can create so now we look at what the best way to imlement those in Rails.

| #   | Relationship       | Enforced in DB by SQL alone | Breaks if you skip callbacks | Breaks if you skip validations |
| --- | ------------------ | --------------------------- | ---------------------------- | ------------------------------ |
| 1.  | `{0..1} to {0..1}` | Yes                         | No                           | No                             |
| 2.  | `{1}    to {0..1}` | Yes                         | No                           | No                             |
| 3.  | `{1..N} to {0..1}` | Partially                   | Yes                          | Yes                            |
| 4.  | `{0..N} to {0..1}` |                             |                              |                                |
| 5.  | `{1}    to {1}`    |                             |                              |                                |
| 6.  | `{1..N} to {1}`    |                             |                              |                                |
| 7.  | `{0..N} to {1}`    |                             |                              |                                |
| 8.  | `{1..N} to {1..N}` |                             |                              |                                |
| 9.  | `{0..N} to {1..N}` |                             |                              |                                |
| 10. | `{0..N} to {0..N}` |                             |                              |                                |

Rails implements relationships with a mixture of the following tools:

1. Database constraints created in migrations
1. Relationship macros e.g. `belongs_to`, `has_one` etc. and the options you pass to them
1. Model validations
1. Model callbacks

We consider Rails validations as "advisory" rather than "enforcing" because they can be skipped e.g. `my_model.save(validate: false)`.  Therefore the best outcome for implementing a relationship will use **both** Rails validations (whether explicitly added by `validates` or implicitly added by the relationship macros) **and** Database constraints.

It isn't always possible to achieve this outcome. And sometimes, while the outcome is possible, there are trade-offs which make us choose not to.

Implementing a relationship in Rails has two phases:

1. Planning Phase
    1. Choose a relationship from the 10 possible
    1. Choose a deletion behaviour for that relationship
1. Implement Phase
    1. Choose macros and options
    1. Choose which side to put each macro
    1. Implement migration
    1. Add validations and callbacks if required

### Problem: SQL Databases have limited support for enforcing 1..N relationships

SQL **declarative** constraints have the following reach:

* Value reach
    * NOT NULL
        * can only reference data within the value being checked
* Row reach
    * CHECK constraint
        * can only reference data within the single row being checked
* Single table reach
    * UNIQUE constraint
        * can reference data within the same table
    * EXCLUDE
        * a more general form of UNIQUE constraint (where the operator doesn't have to be `=`)
* Cross table reach
    * FOREIGN KEY
        * says that a value must be included in the set of values in some other column in another table
        * can say what should happen to the matching rows in the other table when this row is updated/deleted

So `FOREIGN KEY` is the only constraint that can check data across tables. And `FOREIGN KEY` cannot say things like:

> If you create a row in A then some row in B must have a reference to it

So to build some kinds of relationship, we can't get by with declarative SQL statements alone and we need to write code to help enforce the relationship.

This code can be embedded in the database itself and executed via triggers or it can exist at the application layer.

While it is possible to manage DB triggers in Rails (see the [hair_trigger](https://github.com/jenseng/hair_trigger/) gem),
in this document we will put all the logic in the application because that is generally better understood by application developers and therefore easier to maintain than database triggers. Your team may choose to make a different decision here. More power to you.

More specifically this code will be a set of `ActiveRecord` callbacks.

This weakness in SQL leads to a weakness in our implementations!

Because some of the logic is implemented at the ActiveRecord layer, it can be **skipped** e.g. if you use ActiveRecord methods which skip callbacks (e.g. `my_model.delete`) or skip validations e.g. `my_model.save(validate: false)`. This is unfortunate but currently unavoidable.

In these examples we:

1. Try to leverage declarative SQL as much as possible to enforce the relationship because it is safer and executes faster.
2. Fall back to Rails callbacks when necessary because they are easier to manage than database trigger code.

### Rails does not create foreign key constraints by default in migrations.

Rails does not create foreign key constraints by default in migrations. These constraints are very important for maintaining data integrity so we need to add the `foreign_key: true` option whenever possible.

Rails does not create foreign key constraints by default. I don't know why. It _might_ be because

* SQLite didn't support them out of the box and Rails was trying to be as database agnostic as possible.
* Rails implemented deletion support as options to the `has_*` macros e.g. `has_many :things, dependent: :nullify`

Anyway I think it's a bad default.

Foreign key constraints are very important for maintaining data integrity so we need to add the `foreign_key:` option in the migration. Without the foreign key, when you delete a Bravo then the Alfa will still have a "dangling pointer" to it

```ruby
# BEST: creates foreign key which nullifies on delete
add_belongs_to :alfas, :bravo, foreign_key: { on_delete: :nullify } # BEST

# OK: Causes a PG::ForeignKeyViolation to be raised if you try to delete a bravo
# referenced by an alfa. Avoids data integrity issues but forces you to deal
# with exceptions.
add_belongs_to :alfas, :bravo , foreign_key: true # OK

# BAD: no foreign key. Will allow Alfa.bravo_id to reference a row which no
# longer exists. Creates data integrity issues
add_belongs_to :alfas, :bravo # BAD
```


### ??? Good thing: Rails automatically adds an index to the foreign key column (WIP)

We should always add an index to the foreign key column
particularly if you are using the "cascading delete" deletion behaviour (it will generally make that much faster)

    TODO: Does Rails **always** do this? it seems to but I haven't checked all cases

### Good thing: Rails' synthetic ID columns

Rails' use of synthetic id columns for primary keys is a good thing and avoids a lot of problems. It avoids potentially expensive `ON UPDATE` options in our foreign key constraints.

## Part 3: The 10 kinds of relationship in Rails

### 1. {0..1} to {0..1}

#### Overview

Consider the following relationship:

    [Alfa]0..1__________0..1[Bravo]

which reads as:

    Alfa has 0..1 Bravo
    Bravo has 0..1 Alfa

#### Choose: macros and options

Rails implements this using a combination of the `belongs_to` and `has_one` macros.

* Rails will validate a `belongs_to` relationship by default so we need to add the `optional: true` option to make the relationship a `0..1`
* Rails will not validate a `has_one` relationship by default so it naturally creates a `0..1`

#### Choose: which side gets each macro

It does not matter in which model we put the `belongs_to` for this relationship pair so in our example we arbitrarily put `belongs_to` in `Alfa` and `has_one` in `Bravo`.

#### Choose: deletion behaviour

See part 1 for some background on deletion options.

Both sides of the relationship can be 0 i.e. the relationship is optional in both directions. This means that deleting the model on either side of the relationship should not delete the other model.

Instead it should nullify the relationship. This is implemented via a foreign key constraint in the database.

Assuming we put the foreign key in Alfa (i.e. we create the `alfas.bravo_id` column) then

| Deletion behaviour option | When deleting an Alfa | When deleting a Bravo |
| ------------------------- | --------------------- | --------------------- |
| Raise error               | N/A                   | N/A                   |
| Do nothing                | :white_check_mark:    | --                    |
| Cascade delete            | N/A                   | N/A                   |
| Nullify foreign key       | --                    | :white_check_mark:    |

#### Implement: migration options

`null: true` is a default migration option. We explicitly add it because allowing null values is an important part of this relationship so it is better to be explicit.

Rails does not create foreign key constraints by default so we explicitly create one.

#### Implement: Add validations and callbacks (if required)

This relationship does not require any ActiveRecord validations or callbacks.

#### Example code

```ruby
INCLUDE_FILE demo_app/app/models/alfa.rb
```

```ruby
INCLUDE_FILE demo_app/app/models/bravo.rb
```

```ruby
INCLUDE_FILE demo_app/db/migrate/20210704022223_connect_alfa_and_bravo.rb
```

```ruby
INCLUDE_FILE demo_app/spec/models/alfa_bravo_relationship_spec.rb
```

#### Implementation score card:

| Attribute                                   | Result             |
| ------------------------------------------- | ------------------ |
| Relationship integrity enforced by Database | :white_check_mark: |
| Recommended                                 | :white_check_mark: |

### 2. {0..1} to {1}

#### Overview

Consider the following relationship:

    Charlie {0..1} to {1} Deltum

which reads as:

    Charlie has exactly 1 Deltum
    Deltum has 0..1 Charlie

#### Choose: macros and options

Rails implements this bidirectional relationship a combination of the `belongs_to` and `has_one` macros.

#### Choose: which side gets each macro

It is very important that we put the `belongs_to` in the correct model.

The model with the `belongs_to` macro will have an extra column added to its database table. That column contains the id of the related record in the other table.

We can then create a database constraint (remember, those are the "enforcing" kind) which says that the new column cannot be empty. This effectively requires that the relationship exist and the database will refuse to save a record which violates this rule.

However, the other database table has no extra column so we have nothing to apply a database constraint to. It is _technically_ possible to create such a constraint with a database trigger but it's not common to do so.

The bottom line is that if we want to enforce a `{0..1} to {1}` relationship at the database layer, we must put the new column (the foreign key) in the table which has the `{1}` half of the bidirectional relationship.

Another way of thinking about this is that `belongs_to` can create a `{1}` backed by database constraints but `has_one` cannot.

#### Choose: deletion behaviour

The bidirectional relationship

    Charlie {0..1} to {1} Deltum

does not, on its own, tell you how deletions should be handled. You need to choose that as part of your implementation.

For example, when you attempt to delete a Deltum which has an associated Charlie, then that Charlie will be in an forbidden state i.e. the Charlie will exist without a Deltum.

There are two options:

1. Fail the attempt to delete the Deltum with an error (**common**)
    * This allows the application to decide how to handle the error e.g. it might assign the associated Charlie a new Deltum before attempting to delete the Deltum again or it might signal the error to the user or logs.
    * This is the default behaviour when the `on_delete` option is not specified in the migration

    | Deletion behaviour option | When deleting a Charlie | When deleting a Deltum |
    | ------------------------- | ----------------------- | ---------------------- |
    | Raise error               |                         | :white_check_mark:     |
    | Do nothing                | :white_check_mark:      |                        |
    | Cascade delete            |                         |                        |
    | Nullify foreign key       |                         |                        |
2. Automatically Delete the associated Charlie when the Deltum is deleted (**only use if appropriate**)
    * This _may_ be appropriate for your data model. It is very easy to opt-in to automatic deletion with Rails.
    * See the comments in the migration file below for details on how to enable this automatic deletion.

    | Deletion behaviour option | When deleting a Charlie | When deleting a Deltum |
    | ------------------------- | ----------------------- | ---------------------- |
    | Raise error               |                         |                        |
    | Do nothing                | :white_check_mark:      |                        |
    | Cascade delete            |                         | :white_check_mark:     |
    | Nullify foreign key       |                         |                        |

*We choose the first option (raising an error) in the code example below*

#### Implement: migration options

`foreign_key: true` corresponds to Postgres `NO ACTION` which will raise an error when you attempt to delete a record which is referenced by the foreign key column.

`null:false` is required to ensure that the foreign key always has a value (this enforces the `{1}` direction of the relationship).

#### Implement: Add validations and callbacks (if required)

This relationship does not require any ActiveRecord validations or callbacks.

#### Example code

```ruby
INCLUDE_FILE demo_app/app/models/charlie.rb
```

```ruby
INCLUDE_FILE demo_app/app/models/deltum.rb
```

```ruby
INCLUDE_FILE demo_app/db/migrate/20210705071426_connect_charlie_and_deltum.rb
```

```ruby
INCLUDE_FILE demo_app/spec/models/charlie_deltum_relationship_spec.rb
```

#### Implementation score card:

| Attribute                                   | Result             |
| ------------------------------------------- | ------------------ |
| Relationship integrity enforced by Database | :white_check_mark: |
| Recommended                                 | :white_check_mark: |

### 3. {1..N} to {0..1}

#### Overview

Consider the following relationship:

    Gopher {1..N} to {0..1} Hotel

which reads as:

    Gopher has 0..1 Hotel
    Hotel has 1..N Gopher

#### Choose: deletion behaviour

The bidirectional relationship

    Gopher {1..N} to {0..1} Hotel

does not, on its own, tell us what should happen when associated records are deleted.

There are two questions we need to answer:

1. What should happen to any associated Hotel when we delete a Gopher?
2. What should happen to any associated Gophers when we delete a Hotel?


| Deletion behaviour option  | When deleting a Gopher | When deleting a Hotel |
| -------------------------- | ---------------------- | --------------------- |
| Raise error                | :white_check_mark:     |                       |
| Do nothing                 |                        | :white_check_mark:    |
| Cascade delete             |                        |                       |
| Nullify foreign key column |                        |                       |

The answer will depend on your data model but we can work through the options

* When you try to delete a Hotel:
  * it must have at least 1 gopher associated
  * but we can just nullify the gopher side because gopher can have 0 hotel
* When you try to delete a Gopher:
  * it might have an associated Hotel
  * deleting the Gopher might mean that the Hotel will then have 0 gophers which is forbidden

What about SQL?

To implement a database constraint to prevent leaving a Hotel with 0 Gopher when you delete a Gopher, we would need a constraint on `gophers.hotel_id` where every row in `hotels` must appear at least once in `gophers.hotel_id`. This kind of constraint does not exist declaratively in databases but it can be implemented with a `BEFORE DELETE` trigger.

What about Rails?

We need to hook into "just before the delete happens" so we can check both sides of the relationship to see what they would look like if the delete happens. Rails lets us do this with a `before_destroy` callback.

In this guide, we will choose the Rails `before_destroy` callback because it is generally accepted to be easier ot maintain. Your team may make a different choice.


#### Choose: macros and options

Rails implements this bidirectional relationship a combination of the `belongs_to` and `has_many` macros.

You must set `belongs_to(..., optional: true)` to make that side of the relationship `{0..1}`.

#### Choose: which side gets each macro

There is only one choice for which side gets which macro.

#### Implement: migration options

You must set `null: true` in the migration to match the `belongs_to(..., optional: true)` model.

#### Implement: Add validations and callbacks (if required)

Rails has no `has_many(..., required: true)` to make that side of the relationship `{1..N}` so we use a presence validation. Note this does not add any database enforcement of the relationship.

#### Example code

```ruby
INCLUDE_FILE demo_app/app/models/gopher.rb
```

```ruby
INCLUDE_FILE demo_app/app/models/hotel.rb
```

```ruby
INCLUDE_FILE demo_app/db/migrate/20210705184309_connect_gopher_to_hotel.rb
```

```ruby
INCLUDE_FILE demo_app/spec/models/gopher_hotel_relationship_spec.rb
```

#### Implementation score card:

| Attribute                                   | Result             |
| ------------------------------------------- | ------------------ |
| A has 0..1 B integrity enforced by Database | :white_check_mark: |
| B has 1..N A integrity enforced by Database | :x:                |
| The best we can do?                         | :white_check_mark: |

      TODO: check presence validation works

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
* https://docs.gitlab.com/ee/development/foreign_keys.html
* TODO: rails guides

```
ROUGH NOTES

UML notiation has the notation of specifying lifetimes of entities using composition and aggregation diamonds
  this could be used to make the diagrams richer
  and encourage devs to think about lifetimes when modelling
  but it also makes the diagrams more complex
  ???

In UML they can also specify if the elements are ordered and/or unique. That opens oup a whole other set of examples

QUESTION: in what cases do you need to specify inverse_of in rails association? in what instances is it a good idea?

> Automatic inverse detection only works on has_many, has_one, and belongs_to associations.
> :foreign_key and :through options on the associations, or a custom scope, will also prevent the association's inverse from being found automatically.
> The automatic guessing of the inverse association uses a heuristic based on the name of the class, so it may not work for all associations, especially the ones with non-standard names.
> You can turn off the automatic detection of inverse associations by setting the :inverse_of option to false

https://rails.rubystyle.guide/#has_many-has_one-dependent-option
contraticts the advice in gitlab style guide

This is all still WIP

TODO List

* Demo polymporhic assoications. They aren't a new kind but they are diff in Rails e.g. prob need a dependent: option
* explain avoiding dependent: options by default thoughtout

=========================
    the db can do deletions or rails can
    every foreign key should define an ON DELETE clause
    When adding a foreign key in PostgreSQL the column is not indexed automatically, thus you must also add a concurrent index. Not doing so will result in cascading deletes being very slow.

> Don???t define options such as dependent: :destroy or dependent: :delete when defining an association. Defining these options means Rails will handle the removal of data, instead of letting the database handle this in the most efficient way possible

The dependent option implements itself with callbacks I presume
I think it might still be required for polymorphic associations
=========================
#### When is the dependent option good/bad/required?


    https://docs.gitlab.com/ee/development/foreign_keys.html
      says it's bad for perf

    https://rails.rubystyle.guide/#has_many-has_one-dependent-option requires it  for has_one, has_many

    but I think there are cases where it is required?
      once i've worked through the 10 options I'll have a better idea of this

Rails trigger management gem
https://github.com/jenseng/hair_trigger/issues
This could be used to enforce some database triggers
But I still need to identify best practice set of triggers for each relationship
```
