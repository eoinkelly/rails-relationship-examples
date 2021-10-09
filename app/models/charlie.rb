class Charlie < ApplicationRecord
  # Rails 5+ by default will validate that the target of a `belongs_to` exists
  # i.e. Instances of `Alfa` will not be valid unless they have a connected
  # `Bravo`. This naturally creates a {1} relationship.
  #
  belongs_to :deltum
end
