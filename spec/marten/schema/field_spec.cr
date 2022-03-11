require "./spec_helper"

describe Marten::Schema::Field do
  describe "#registry" do
    it "returns the expected field abstractions" do
      Marten::Schema::Field.registry.size.should eq 5
      Marten::Schema::Field.registry["bool"].should eq Marten::Schema::Field::Bool
      Marten::Schema::Field.registry["float"].should eq Marten::Schema::Field::Float
      Marten::Schema::Field.registry["int"].should eq Marten::Schema::Field::Int
      Marten::Schema::Field.registry["string"].should eq Marten::Schema::Field::String
      Marten::Schema::Field.registry["uuid"].should eq Marten::Schema::Field::UUID
    end
  end
end