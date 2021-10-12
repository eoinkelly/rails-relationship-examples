require "rails_helper"

##
# These specs exist to help explain the relationship. You shouldn't copy these
# directly into your app without considering whether they provide long-term
# value to you.
#
RSpec.describe "Alfa {0..1} <--> {0..1} Bravo", type: :model do
  describe "Alfa has {0..1} Bravo" do
    it "Alfa is valid with 0 Bravo" do
      alfa = Alfa.new

      expect(alfa.bravo).to eq(nil)
      expect(alfa.valid?).to eq(true)

      alfa.save!
      expect(alfa.persisted?).to eq(true)
    end

    it "Alfa is valid with 1 Bravo" do
      bravo = Bravo.new
      alfa = Alfa.new(bravo: bravo)

      expect(alfa.valid?).to eq(true)
      expect(alfa.bravo).to eq(bravo)

      alfa.save!
      expect(alfa.persisted?).to eq(true)
    end
  end

  describe "Bravo has {0..1} Alfa" do
    it "Bravo is valid with 0 Alfa" do
      bravo = Bravo.new

      expect(bravo.alfa).to eq(nil)
      expect(bravo.valid?).to eq(true)

      bravo.save!
      expect(bravo.persisted?).to eq(true)
    end

    it "Bravo is valid with 1 Alfa" do
      alfa = Alfa.new
      bravo = Bravo.new(alfa: alfa)

      expect(bravo.valid?).to eq(true)
      expect(bravo.alfa).to eq(alfa)

      bravo.save!
      expect(bravo.persisted?).to eq(true)
    end
  end

  describe "deletions" do
    it "When the Alfa is deleted, Bravo is not changed" do
      bravo = Bravo.create!
      alfa = Alfa.create!(bravo: bravo)

      alfa.destroy

      expect(Bravo.count).to eq(1)
    end

    it "When the Bravo is deleted, Alfa's foreign key col is nullified by the DB foreign key constraint" do
      bravo = Bravo.create!
      Alfa.create!(bravo: bravo)

      bravo.destroy

      expect(Alfa.count).to eq(1)
      expect(Alfa.first.bravo_id).to eq(nil)
    end
  end
end
