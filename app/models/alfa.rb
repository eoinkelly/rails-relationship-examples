class Alfa < ApplicationRecord
  # optional: true
  #   Rails 5+ by default will validate that the target of a `belongs_to` exists
  #   i.e. Instances of `Alfa` will not be valid unless they have a connected
  #   `Bravo`. We want Alfas to have 0..1 Bravos so we must add `optional: true`.
  # inverse_of:
  #   We choose to always set and explicit `inverse_of` so that we don't have to
  #   remember the various edge cases where it is required and/or recommended.
  belongs_to :bravo, optional: true, inverse_of: :alfa
end
