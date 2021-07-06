class Hotel < ApplicationRecord
  has_many :golves,
           # Setting inverse_of is generally a good practice
           inverse_of: :hotel,

           # It isn't part of creating the relationship but it is good practice to
           # always explicitly choose a value for `dependent` option. `nil` (do
           # nothing) is the default. See
           # https://api.rubyonrails.org/v6.1.3.2/classes/ActiveRecord/Associations/ClassMethods.html#method-i-belongs_to
           # for details.
           dependent: nil

  # Use a validation to try to "enforce" that a Hotel always has {1..N} Golves
  # i.e. **at least** 1 Golf. This isn't really enforcing because there is a
  # bunch of Rails API for doing things skipping validations.
  validates :captains, presence: true
end
