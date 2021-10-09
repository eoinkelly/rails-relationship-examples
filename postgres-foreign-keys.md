## Foreign key constraints in PostgreSQL

```sql
CREATE TABLE items (
    id bigint PRIMARY KEY,
    name text,
    price numeric
);

CREATE TABLE orders (
    id bigint PRIMARY KEY,
    total numeric

    -- ************** options **************

    -- * default
    -- * raises an error if you try to delete a row in `items` which is referenced by this row in `orders`
    -- * allows the check to be deferred to later in the transaction
    item_id REFERENCES items ON DELETE NO ACTION,

    -- does not allow the check to be deferred to later in the transaction
    item_id REFERENCES items ON DELETE RESTRICT,

    -- when a referenced row is deleted, rows referencing it should be deleted too
    item_id REFERENCES items ON DELETE CASCADE,

    -- set the referencing column(s) to null
    item_id REFERENCES items ON DELETE SET NULL,

    -- set the referencing column(s) (remember it could be multiple cols) to their default value
    item_id REFERENCES items ON DELETE SET DEFAULT,
);
```

### Terminology

    referencing_col {type} REFERENCES other_table(referenced_col)

    there is a referenced table and a referencing table
    there are referenced columns and a referencing columns

### Foreign key ON DELETE options

All these answer the question "What should happen to the pointer if the thing it points to is deleted?"

* NO ACTION (default)
    * this is default if you don't specify anything
    * if any referencing rows exist then raise an error
    * this check can be deferred to the end of the transaction
    * kicks in when you try to delete a **referenced** row (a row whose col(s) are referenced by another table)
    * it's like a less strict version of RESTRICT
* RESTRICT
    * prevents deletion of a **referenced** row
    * this check **cannot** be deferred to the end of the transaction
    * kicks in when you try to delete a **referenced** row (a row whose col(s) are referenced by another table)
* CASCADE
    * when a referenced row is deleted, then all the referencing rows should be deleted too
    * kicks in when you try to delete a **referenced** row (a row whose col(s) are referenced by another table)
    * takes action on tables other than the one you are running the `DELETE FROM ...` on
* SET NULL
    * when a referenced row is deleted, then all the referencing rows have their referencing cols set to `NULL`
    * kicks in when you try to delete a **referenced** row (a row whose col(s) are referenced by another table)
    * takes action on tables other than the one you are running the `DELETE FROM ...` on
* SET DEFAULT
    * when a referenced row is deleted, then all the referencing rows have their referencing cols set to their default values
    * kicks in when you try to delete a **referenced** row (a row whose col(s) are referenced by another table)
    * takes action on tables other than the one you are running the `DELETE FROM ...` on

All these constraints kick in when you try to delete a **referenced** row i.e. a row from the table that doesn't have the foreign key

These constraints do not change what happens when you delete a **referencing** row.

The goal of the constraint is to keep the **referencing** row valid
The ON DELETE option specifies what should happen when

Analogy:

The referencing row is like a pointer to a value, rather than the value itself
  You can delete the pointer without changning the referenced row
  but if you delete the referenced thing then you need to either:
    delete the pointer
    error
    nullify the pointer


In Rails terms: These constraints kick in when you delete the model that has the has_one/has_many, not when you delete the model which has belongs_to

Attempting to delete a referenced row will result in a scan of all the referencing tables so you should put indexes on every foreign key
Declaration of a foreign key constraint does not automatically create an index

### Foreign key ON UPDATE options

* `ON UPDATE` is invoked when a **referenced** column is changed (updated).
* The possible actions are the same as `ON DELETE` except:
    * CASCADE means that the updated values of the referenced column(s) should be **copied** into the referencing row(s).

`ON UPDATE` doesn't really come up if your database design uses synthetic ID keys. It can come up if you use "data columns" for primary key e.g. imagine you have users and avatars. If you used users.email as the primary key of users, then the referencing column might be `pictures.user_email`. In this case, if you need to update the user's email, then all the referencing columns have to be updated too.

Summary: Synthetic ID columns are a good idea!

### Foreign key NOT VALID option

* currently only allowed for foreign key constraints.
* If the constraint is marked NOT VALID, the potentially-lengthy initial check to verify that all rows in the table satisfy the constraint is skipped.
* The constraint will still be enforced against subsequent inserts or updates (that is, they'll fail unless there is a matching row in the referenced table).
* But the database will not assume that the constraint holds for all rows in the table, until it is validated by using the VALIDATE CONSTRAINT option.

Use this as a first step when introducing a foreign key constraint to existing data. It enforces the constraint for new rows.
Your second step is to fixup old rows to also validate the constraint. Then you can turn on the constraint fully.

### Rails add_foreign_key options

    :on_delete
    Action that happens ON DELETE. Valid values are :nullify, :cascade and :restrict

    :on_update
    Action that happens ON UPDATE. Valid values are :nullify, :cascade and :restrict

    :validate
    (PostgreSQL only) Specify whether or not the constraint should be validated. Defaults to true.


# Postgres constraint reach

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
        * can say waht should happen to the matching rows in the other table when this row is updated/deleted

You can define **imperative** constraints with triggers which can be more flexible

SQL has no delcarative way of saying "if you create a row in A you must also edit/create new row in B"
so in general it can only declaratively enforce 1.. relationships  if it can be implemented by adding a column to A or B
join tables are naturally 0..N <--> 0..N
can they be made otherwise by SQL?

> Unfortunately SQL doesn't have an "at-least-one-to-many" relationship (not that I know of anyway :) ), so any solution you come up with is going to involve some compromise.

The comporomise could be

1. Add extra cols to your tables and custom logic to fully enforce the 1..N constraint
  * the extra logic could be in a DB trigger or in your app code
  * Q: are there good ways to manage db triggers in Rails?
  * Rails provides callbacks which we can use to implement this logic in the app layer
    * callbacks are on associations too e.g. on_add, on_remove etc.

The comporomise is that if you use ActiveRecord and don't skip validations you can get the rules you want
The SQL layer can't do it all for you
So does this validate Rails' choice to do everything at the app layer?

So my doc

1. Tries to leverage the DBMS as much as possible
2. Falls back to Rails callbacks because they are the easiest to manage, assuming that you never skip validations

