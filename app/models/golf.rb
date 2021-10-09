class Golf < ApplicationRecord
  # optional: true
  #   Rails 5+ by default will validate that the target of a `belongs_to` exists
  #   i.e. Instances of `Golf` will not be valid unless they have a connected
  #   `Hotel`. We want Glof to have 0..1 Bravos so we must add `optional: true`.
  #
  # dependent:
  #   We do not specify it here. It is not recommended to set it to anything
  #   other than it's default "do nothing" value.
  belongs_to :hotel, optional: true

  before_destroy :check_hotel_still_would_still_have_at_least_one_golf

  private

  def check_hotel_still_would_still_have_at_least_one_golf
    return if hotel.nil?

    # Prevent destroying this object if the asociated hotel would have no golves afterwards.
    if hotel.golves.count <= 1
      # TODO: is it appropriate to add an error here or shoudl I just fail?
      # errors.add(:base, :hotel_must_have_at_least_one_golf, message: "Assoicated Hotel must still have at least one Golf")
      throw(:abort)
    end
  end
end
