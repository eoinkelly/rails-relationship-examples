class Deltum < ApplicationRecord
  # Rails does not validate that the target of a `has_one` exists so it
  # naturally creats a 0..1 relationship.
  #
  has_one :charlie
end
