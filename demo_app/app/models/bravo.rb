class Bravo < ApplicationRecord
  # Rails does not validate that the target of a `has_one` exists so it
  # naturally creates a 0..1 relationship.
  #
  has_one :alfa
end
