
1. Refuse to delete the record and raise an exception (common)
1. Nullify the referencing column (common).
1. Take No Action (common if any side of the relationship can have 0 items i.e. `0..`).
    * We need to be careful with this one to ensure we don't leave a DB column with a reference to an ID in another table which no longer exists!
1. Automatically delete all referencing rows when a row is deleted, also known as a _Cascade delete_ (uncommon)

| Raise error | |
| Do nothing | |
| Cascade delete| |
| Nullify | |


jargon

bidirectional relationship
### Problem: Explicit inverse_of can't be used everywhere

Rails will attempt to automatically guess the inverse relationship in many cases. This automatic detection fails if

* You use custom foreign key name with `foreign_key: ` option on the association
* You add a custom scope to the association
* You use the `through:` option on the association
* The class names do not line up such that Rails can guess the class name.

Because of the large number of cases where automatic inverse guessing does not work, we think it is clearer to always add an explicit `inverse_of` so that you don't have to remember those edge cases. All the examples below specify an explicit `:inverse_of` option.

Your team may choose to rely on Rails' automatic `inverse_of` guessing without harming the quality of the implementation, provided the whole team understands the exceptions above and adds explicit `inverse_of` options where required.


has_one :foo # has 0..1
belongs_to :foo # has 1..1
belongs_to :foo, optional: true # has 0..1

add_belongs_to will create a non-unique index on the foreign key

foreign_key: false # efault
foreign_key: true # NO ACTION, like :restrict but is deferrable
foreign_key: { on_delete: :cascade }
foreign_key: { on_delete: :nullify }
foreign_key: { on_delete: :restrict }



deletion behaviour implemntation depends on which side gets the belongs_to



Planning Phase

1. Choose a relationship

within each realationship: Implement Phase

1. Overview
1. Choose macros and options
1. Choose which side gets each macro
1. Choose deletion behaviour
1. Choose migration options
1. Add validations and callbacks if required

TEMPLATE =====================================================

#### Overview


#### Choose deletion behaviour


#### Choose macros and options


#### Choose which side gets each macro


#### Choose migration options


#### Add validations and callbacks (if required)

