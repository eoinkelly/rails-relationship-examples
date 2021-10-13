class Gopher < ApplicationRecord
  # optional: true
  #   Rails 5+ by default will validate that the target of a `belongs_to` exists
  #   i.e. Instances of `Gopher` will not be valid unless they have a connected
  #   `Hotel`. We want Glof to have 0..1 Bravos so we must add `optional: true`.
  belongs_to :hotel, optional: true

  # Prevent destroying this object if the asociated Hotel would have no Gophers
  # afterwards.
  before_destroy :check_hotel_still_would_still_have_at_least_one_gopher

  private

  def check_hotel_still_would_still_have_at_least_one_gopher
    # Do nothing if this Gopher doesn't have a Hotel
    return if hotel.nil?

    # Otherwise stop the deletion if deleting this Gopher would leave the
    # associated Hotel with 0 Gophers.
    if hotel.gophers.count <= 1
      errors.add(:base,
        :associated_hotel_would_become_invalid,
        message: "Destroying this object would leave associated Hotel with invalid relationship"
      )

      throw(:abort)
    end
  end
end
