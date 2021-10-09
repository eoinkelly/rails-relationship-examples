require "rails_helper"

##
# These specs exist to help explain the relationship. You shouldn't copy these
# directly into your app without considering whether they provide long-term
# value to you.
#
RSpec.describe "Golf {1..N} <--> {0..1} Hotel", type: :model do
  describe "Golf has {0..1} Hotel" do
    describe "Golf has {0} Hotel" do
      it "Golf is valid with 0 Hotel" do
        golf = Golf.new

        expect(golf.hotel).to eq(nil)
        expect(golf.valid?).to eq(true)
      end

      it "Golf can be saved with 0 Hotel (when validations enabled)" do
        golf = Golf.new
        golf.save!
        expect(golf.persisted?).to eq(true)
      end

      it "Golf can be saved with 0 Hotel (when validations disabled)" do
        golf = Golf.new
        golf.save!(validate: false)
        expect(golf.persisted?).to eq(true)
      end
    end

    describe "Golf has {1} Hotel" do
      it "Golf is valid with 1 Hotel" do
        hotel = Hotel.new
        golf = Golf.new(hotel: hotel)

        expect(golf.valid?).to eq(true)
      end

      it "Golf can be saved with 1 Hotel (when validations enabled)" do
        hotel = Hotel.new
        golf = Golf.new(hotel: hotel)

        golf.save!

        expect(golf.persisted?).to eq(true)
      end

      it "Golf can be saved with 1 Hotel (when validations disabled)" do
        hotel = Hotel.new
        golf = Golf.new(hotel: hotel)

        golf.save!(validate: false)

        expect(golf.persisted?).to eq(true)
      end
    end

    describe "Deletions" do
      it "Deleting a Golf: Succeeds if the Golf has 0 Hotel" do
        # Given a Gold that has 0 Hotel
        golf = Golf.create!(hotel: nil)

        # When we attempt to destroy the Golf
        golf.destroy!

        # it should succeed.
        expect(Golf.count).to eq(0)
      end

      it "Deleting a Golf: Succeeds if Golf a Hotel which has other Golf" do
        # If the Golf has a Hotel
        # then we can only delete the golf if that Hotel would still have at least one Golf after the deletion

        # Given a a Hotel which has two associated Golf
        golf_1 = Golf.create!
        golf_2 = Golf.create!
        hotel = Hotel.create!(golves: [golf_1, golf_2])

        # when we attempt to destroy one of the Golf instances
        golf_1.destroy!

        # then this should succeed because the Hotel still has 1 Golf
        expect(Hotel.count).to eq(1)
        expect(Golf.count).to eq(1)
      end

      it "Deleting a Golf: Fails if Golf has a Hotel which has no other Golf" do
        # Given a a Hotel which has {1} Golf
        golf = Golf.create!
        hotel = Hotel.create!(golves: [golf])

        # When we attempt to destroy the Golf
        # Then it raises an error
        expect { golf.destroy! }.to raise_error(ActiveRecord::RecordNotDestroyed)

        # and the original Golf and Hotel still exist
        expect(Hotel.count).to eq(1)
        expect(Golf.count).to eq(1)
      end
    end
  end

  describe "Hotel has {1..N} Golf" do
    describe "Hotel has {0} Golf" do
      it "Hotel is not valid with 0 Golf" do
        hotel = Hotel.new

        expect(hotel.golves).to eq([])
        expect(hotel.valid?).to eq(false)
      end

      it "Hotel cannot be saved with 0 Golf (when validations enabled)" do
        hotel = Hotel.new

        expect { hotel.save! }.to raise_error(ActiveRecord::RecordInvalid)

        expect(hotel.persisted?).to eq(false)
      end

      it "IMPLEMENTATION WEAKNESS: Hotel can still be saved with 0 Golf (when validations disabled)" do
        hotel = Hotel.new

        expect { hotel.save!(validate: false) }.not_to raise_error
      end
    end

    describe "Hotel has {1} Golf" do
      it "Hotel is valid with 1 Golf" do
        golf = Golf.new
        hotel = Hotel.new(golves: [golf])

        expect(hotel.valid?).to eq(true)
      end

      it "Hotel can be saved with 1 Golf (when validations enabled)" do
        golf = Golf.new
        hotel = Hotel.new(golves: [golf])

        hotel.save!

        expect(hotel.persisted?).to eq(true)
      end

      it "Hotel can be saved with 1 Golf (when validations disabled)" do
        golf = Golf.new
        hotel = Hotel.new(golves: [golf])

        hotel.save!(validate: false)

        expect(hotel.persisted?).to eq(true)
      end

      it "Hotel can be deleted with 1 Golf" do
        golf_1 = Golf.create!
        hotel = Hotel.create!(golves: [golf_1])

        # When we destroy the Hotel
        hotel.destroy!

        # we expect the Golf objects still exist
        expect(Hotel.count).to eq(0)
        expect(Golf.count).to eq(1)
        golf_1.reload
        expect(golf_1.hotel).to eq(nil)
      end
    end

    describe "Hotel has {N} Golf" do
      it "Hotel is valid with N=2 Golf" do
        golf_1 = Golf.new
        golf_2 = Golf.new
        hotel = Hotel.new(golves: [golf_1, golf_2])

        expect(hotel.valid?).to eq(true)
      end

      it "Hotel can be saved with N=2 Golf (when validations enabled)" do
        golf_1 = Golf.new
        golf_2 = Golf.new
        hotel = Hotel.new(golves: [golf_1, golf_2])

        hotel.save!

        expect(hotel.persisted?).to eq(true)
      end

      it "Hotel can be saved with N=2 Golf (when validations disabled)" do
        golf_1 = Golf.new
        golf_2 = Golf.new
        hotel = Hotel.new(golves: [golf_1, golf_2])

        hotel.save!(validate: false)

        expect(hotel.persisted?).to eq(true)
      end

      it "Hotel can be deleted with N=2 Golf" do
        golf_1 = Golf.create!
        golf_2 = Golf.create!
        hotel = Hotel.create!(golves: [golf_1, golf_2])

        # When we destroy the Hotel
        hotel.destroy!

        # we expect the Golf objects still exist
        expect(Hotel.count).to eq(0)
        expect(Golf.count).to eq(2)
        golf_1.reload
        golf_2.reload
        expect(golf_1.hotel).to eq(nil)
        expect(golf_2.hotel).to eq(nil)
      end
    end

    describe "Deletions" do
      # If deleting a Hotel should automatically delete the corresponding
      # Golf, see the migration for details on how to implement this.
      # it "Attempting to delete a Hotel with 1 associated Golf fails" do
      #   hotel = Hotel.create!
      #   Golf.create!(hotel: hotel)

      #   expect { hotel.destroy }.to raise_error(ActiveRecord::InvalidForeignKey)

      #   expect(Golf.count).to eq(1)
      #   expect(Hotel.count).to eq(1)
      # end

      # it "Deleting a Hotel with 0 associated Golf succeeds" do
      #   hotel = Hotel.create!

      #   hotel.destroy!

      #   expect(Hotel.count).to eq(0)
      # end
    end
  end
end
