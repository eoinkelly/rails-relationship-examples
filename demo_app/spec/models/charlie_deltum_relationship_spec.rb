require "rails_helper"

##
# These specs exist to help explain the relationship. You shouldn't copy these
# directly into your app without considering whether they provide long-term
# value to you.
#
RSpec.describe "Charlie {0..1} <--> {1} Deltum", type: :model do
  describe "Charlie has {1} Deltum" do
    it "Charlie is not valid with 0 Deltum" do
      charlie = Charlie.new

      expect(charlie.deltum).to eq(nil)
      expect(charlie.valid?).to eq(false)
    end

    it "Charlie cannot be saved with 0 Deltum (when validations enabled)" do
      charlie = Charlie.new
      expect { charlie.save! }.to raise_error(ActiveRecord::RecordInvalid)
    end

    it "Charlie cannot be saved with 0 Deltum (when validations disabled)" do
      # this demonstrates that even when Rails validations are skipped, the
      # database constraint will enforce the relationship
      charlie = Charlie.new
      expect { charlie.save!(validate: false) }.to raise_error(ActiveRecord::NotNullViolation)
    end

    it "Charlie is valid with 1 Deltum" do
      deltum = Deltum.new
      charlie = Charlie.new(deltum: deltum)

      expect(charlie.valid?).to eq(true)
    end

    it "Charlie can be saved with 1 Deltum (when validations enabled)" do
      deltum = Deltum.new
      charlie = Charlie.new(deltum: deltum)

      charlie.save!

      expect(charlie.persisted?).to eq(true)
    end

    it "Charlie can be saved with 1 Deltum (when validations disabled)" do
      deltum = Deltum.new
      charlie = Charlie.new(deltum: deltum)

      charlie.save!(validate: false)

      expect(charlie.persisted?).to eq(true)
    end

    it "Deleting a Charlie does nothing to the Deltum" do
      # Deltum has {0..1} Charlie
      # so it's fine for the Deltum to exist without the Charlie
      deltum = Deltum.create!
      charlie = Charlie.create!(deltum: deltum)

      charlie.destroy

      expect(Deltum.count).to eq(1)
      expect(Deltum.first.charlie).to eq(nil)
    end
  end

  describe "Deltum has {0..1} Charlie" do
    it "Deltum is valid with 0 Charlie" do
      deltum = Deltum.new

      expect(deltum.charlie).to eq(nil)
      expect(deltum.valid?).to eq(true)
    end

    it "Deltum can be saved with 0 Charlie (when validations enabled)" do
      deltum = Deltum.new

      deltum.save!

      expect(deltum.persisted?).to eq(true)
    end

    it "Deltum can be saved with 0 Charlie (when validations disabled)" do
      deltum = Deltum.new

      deltum.save!(validate: false)

      expect(deltum.persisted?).to eq(true)
    end

    it "Deltum is valid with 1 Charlie" do
      charlie = Charlie.new
      deltum = Deltum.new(charlie: charlie)

      expect(deltum.valid?).to eq(true)
    end

    it "Deltum can be saved with 1 Charlie (when validations enabled)" do
      charlie = Charlie.new
      deltum = Deltum.new(charlie: charlie)

      deltum.save!

      expect(deltum.persisted?).to eq(true)
    end

    it "Deltum can be saved with 1 Charlie (when validations disabled)" do
      charlie = Charlie.new
      deltum = Deltum.new(charlie: charlie)

      deltum.save!(validate: false)

      expect(deltum.persisted?).to eq(true)
    end

    # If deleting a Deltum should automatically delete the corresponding
    # Charlie, see the migration for details on how to implement this.
    it "Attempting to delete a Deltum with 1 associated Charlie fails" do
      deltum = Deltum.create!
      Charlie.create!(deltum: deltum)

      expect { deltum.destroy }.to raise_error(ActiveRecord::InvalidForeignKey)

      expect(Charlie.count).to eq(1)
      expect(Deltum.count).to eq(1)
    end

    it "Deleting a Deltum with 0 associated Charlie succeeds" do
      deltum = Deltum.create!

      deltum.destroy!

      expect(Deltum.count).to eq(0)
    end
  end
end
