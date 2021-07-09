class Deltum < ApplicationRecord
  # Rails does not validate that the target of a `has_one` exists so it
  # naturally creats a 0..1 relationship.
  #
  # inverse_of:
  #   We choose to always set and explicit `inverse_of` so that we don't have to
  #   remember the various edge cases where it is required and/or recommended.
  has_one :charlie, inverse_of: :deltum
end
