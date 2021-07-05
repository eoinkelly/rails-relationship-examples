class Deltum < ApplicationRecord
  # Rails does not validate that the target of a `has_one` exists so `has_one`
  # naturally creates a `{0..1}` relationship
  has_one :charlie,
          # Setting inverse_of is generally a good practice
          inverse_of: :deltum,

          # It isn't part of creating the relationship but it is good practice to
          # always explicitly choose a value for `dependent` option. `nil` (do
          # nothing) is the default. See
          # https://api.rubyonrails.org/v6.1.3.2/classes/ActiveRecord/Associations/ClassMethods.html#method-i-belongs_to
          # for details.
          dependent: nil
end
