require "rails_helper"

##
# These specs exist to help explain the relationship. You shouldn't copy these
# directly into your app without considering whether they provide long-term
# value to you.
#
RSpec.describe "Gopher {1..N} <--> {0..1} Hotel", type: :model do
  describe "Gopher has {0..1} Hotel" do
    describe "Gopher has {0} Hotel" do
      it "Gopher is valid with 0 Hotel" do
        gopher = Gopher.new

        expect(gopher.hotel).to eq(nil)
        expect(gopher.valid?).to eq(true)
      end

      it "Gopher can be saved with 0 Hotel (when validations enabled)" do
        gopher = Gopher.new
        gopher.save!
        expect(gopher.persisted?).to eq(true)
      end

      it "Gopher can be saved with 0 Hotel (when validations disabled)" do
        gopher = Gopher.new
        gopher.save!(validate: false)
        expect(gopher.persisted?).to eq(true)
      end
    end

    describe "Gopher has {1} Hotel" do
      it "Gopher is valid with 1 Hotel" do
        hotel = Hotel.new
        gopher = Gopher.new(hotel: hotel)

        expect(gopher.valid?).to eq(true)
      end

      it "Gopher can be saved with 1 Hotel (when validations enabled)" do
        hotel = Hotel.new
        gopher = Gopher.new(hotel: hotel)

        gopher.save!

        expect(gopher.persisted?).to eq(true)
      end

      it "Gopher can be saved with 1 Hotel (when validations disabled)" do
        hotel = Hotel.new
        gopher = Gopher.new(hotel: hotel)

        gopher.save!(validate: false)

        expect(gopher.persisted?).to eq(true)
      end
    end

    describe "Deletions" do
      it "Deleting a Gopher: Succeeds if the Gopher has 0 Hotel" do
        # Given a Gold that has 0 Hotel
        gopher = Gopher.create!(hotel: nil)

        # When we attempt to destroy the Gopher
        gopher.destroy!

        # it should succeed.
        expect(Gopher.count).to eq(0)
      end

      it "Deleting a Gopher: Succeeds if Gopher a Hotel which has other Gopher" do
        # If the Gopher has a Hotel
        # then we can only delete the gopher if that Hotel would still have at least one Gopher after the deletion

        # Given a a Hotel which has two associated Gopher
        gopher_1 = Gopher.create!
        gopher_2 = Gopher.create!
        hotel = Hotel.create!(gophers: [gopher_1, gopher_2])

        # when we attempt to destroy one of the Gopher instances
        gopher_1.destroy!

        # then this should succeed because the Hotel still has 1 Gopher
        expect(Hotel.count).to eq(1)
        expect(Gopher.count).to eq(1)
      end

      it "Deleting a Gopher: Fails if Gopher has a Hotel which has no other Gopher" do
        # Given a a Hotel which has {1} Gopher
        gopher = Gopher.create!
        hotel = Hotel.create!(gophers: [gopher])

        # When we attempt to destroy the Gopher
        # Then it raises an error
        expect { gopher.destroy! }.to raise_error(ActiveRecord::RecordNotDestroyed)

        # and the original Gopher and Hotel still exist
        expect(Hotel.count).to eq(1)
        expect(Gopher.count).to eq(1)
      end
    end
  end

  describe "Hotel has {1..N} Gopher" do
    describe "Hotel has {0} Gopher" do
      it "Hotel is not valid with 0 Gopher" do
        hotel = Hotel.new

        expect(hotel.gophers).to eq([])
        expect(hotel.valid?).to eq(false)
      end

      it "Hotel cannot be saved with 0 Gopher (when validations enabled)" do
        hotel = Hotel.new

        expect { hotel.save! }.to raise_error(ActiveRecord::RecordInvalid)

        expect(hotel.persisted?).to eq(false)
      end

      it "IMPLEMENTATION WEAKNESS: Hotel can still be saved with 0 Gopher (when validations disabled)" do
        hotel = Hotel.new

        expect { hotel.save!(validate: false) }.not_to raise_error
      end
    end

    describe "Hotel has {1} Gopher" do
      it "Hotel is valid with 1 Gopher" do
        gopher = Gopher.new
        hotel = Hotel.new(gophers: [gopher])

        expect(hotel.valid?).to eq(true)
      end

      it "Hotel can be saved with 1 Gopher (when validations enabled)" do
        gopher = Gopher.new
        hotel = Hotel.new(gophers: [gopher])

        hotel.save!

        expect(hotel.persisted?).to eq(true)
      end

      it "Hotel can be saved with 1 Gopher (when validations disabled)" do
        gopher = Gopher.new
        hotel = Hotel.new(gophers: [gopher])

        hotel.save!(validate: false)

        expect(hotel.persisted?).to eq(true)
      end

      it "Hotel can be deleted with 1 Gopher" do
        gopher_1 = Gopher.create!
        hotel = Hotel.create!(gophers: [gopher_1])

        # When we destroy the Hotel
        hotel.destroy!

        # we expect the Gopher objects still exist
        expect(Hotel.count).to eq(0)
        expect(Gopher.count).to eq(1)
        gopher_1.reload
        expect(gopher_1.hotel).to eq(nil)
      end
    end

    describe "Hotel has {N} Gopher" do
      it "Hotel is valid with N=2 Gopher" do
        gopher_1 = Gopher.new
        gopher_2 = Gopher.new
        hotel = Hotel.new(gophers: [gopher_1, gopher_2])

        expect(hotel.valid?).to eq(true)
      end

      it "Hotel can be saved with N=2 Gopher (when validations enabled)" do
        gopher_1 = Gopher.new
        gopher_2 = Gopher.new
        hotel = Hotel.new(gophers: [gopher_1, gopher_2])

        hotel.save!

        expect(hotel.persisted?).to eq(true)
      end

      it "Hotel can be saved with N=2 Gopher (when validations disabled)" do
        gopher_1 = Gopher.new
        gopher_2 = Gopher.new
        hotel = Hotel.new(gophers: [gopher_1, gopher_2])

        hotel.save!(validate: false)

        expect(hotel.persisted?).to eq(true)
      end

      it "Hotel can be deleted with N=2 Gopher" do
        gopher_1 = Gopher.create!
        gopher_2 = Gopher.create!
        hotel = Hotel.create!(gophers: [gopher_1, gopher_2])

        # When we destroy the Hotel
        hotel.destroy!

        # we expect the Gopher objects still exist
        expect(Hotel.count).to eq(0)
        expect(Gopher.count).to eq(2)
        gopher_1.reload
        gopher_2.reload
        expect(gopher_1.hotel).to eq(nil)
        expect(gopher_2.hotel).to eq(nil)
      end
    end

    describe "Deletions" do
      # If deleting a Hotel should automatically delete the corresponding
      # Gopher, see the migration for details on how to implement this.
      # it "Attempting to delete a Hotel with 1 associated Gopher fails" do
      #   hotel = Hotel.create!
      #   Gopher.create!(hotel: hotel)

      #   expect { hotel.destroy }.to raise_error(ActiveRecord::InvalidForeignKey)

      #   expect(Gopher.count).to eq(1)
      #   expect(Hotel.count).to eq(1)
      # end

      # it "Deleting a Hotel with 0 associated Gopher succeeds" do
      #   hotel = Hotel.create!

      #   hotel.destroy!

      #   expect(Hotel.count).to eq(0)
      # end
    end
  end
end
