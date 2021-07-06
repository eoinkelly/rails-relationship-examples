class Golf < ApplicationRecord
  belongs_to :hotel,
             # Rails 5+ by default will validate that the target of a `belongs_to` exists
             # i.e. Instances of `Golf` will not be valid unless they have a connected
             # `Hotel`.
             #
             # We want Golves to have 0..1 Hotels so we must add `optional: true`
             optional: true,

             # Setting inverse_of is generally a good practice
             inverse_of: :golves,

             # It isn't part of creating the relationship but it is good practice to
             # always explicitly choose a value for `dependent` option. `nil` (do
             # nothing) is the default. See
             # https://api.rubyonrails.org/v6.1.3.2/classes/ActiveRecord/Associations/ClassMethods.html#method-i-belongs_to
             # for details.
             dependent: nil
end
