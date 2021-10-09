class Hotel < ApplicationRecord
  # Use a validation to try to "enforce" that a Hotel always has {1..N} Golves
  # i.e. **at least** 1 Golf. This isn't really enforcing because there is a
  # bunch of Rails API for doing things skipping validations.
  # Also this only kicks in for operations on Hotel, it won't cover operations on Golf
  validates :golves, presence: true
  # TODO: is this the right validation? should it be "has at least one" or similar?
end
