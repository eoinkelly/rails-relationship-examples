class Alfa < ApplicationRecord
  # optional: true
  #     Rails 5+ by default will validate that the target of a `belongs_to` exists
  #     i.e. Instances of `Alfa` will not be valid unless they have a connected
  #     `Bravo`. We want Alfas to have 0..1 Bravos so we must add `optional: true`.
  #
  belongs_to :bravo, optional: true
end
