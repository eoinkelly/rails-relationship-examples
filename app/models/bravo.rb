class Bravo < ApplicationRecord
  # Rails does not validate that the target of a `has_one` exists
  has_one :alfa,
          # Setting inverse_of is generally a good practice
          inverse_of: :bravo,

          # It isn't part of creating the relationship but it is good practice to
          # always explicitly choose a value for `dependent` option. `nil` (do
          # nothing) is the default. See
          # https://api.rubyonrails.org/v6.1.3.2/classes/ActiveRecord/Associations/ClassMethods.html#method-i-belongs_to
          # for details.
          dependent: nil
end
