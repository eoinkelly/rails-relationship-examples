class Hotel < ApplicationRecord
  has_many :gophers

  # Use a validation to try to "enforce" that a Hotel always has {1..N} Gophers
  # i.e. **at least** 1 Gopher. Using a presence validation on the association
  # is the recommended Rails way to validate that an associated object exists -
  # see https://guides.rubyonrails.org/active_record_validations.html#presence
  #
  # This isn't really "enforcing" because there are ActiveRecord methods which
  # skip validations.  Also this only works for operations on Hotel - it won't
  # prevent any operations on Gopher so we must also implement a
  # `before_destroy` callback in Gopher.
  validates :gophers, presence: true
end
