require "./spec_helper"

describe Marten::Schema::Field::DateTime do
  describe "#deserialize" do
    it "returns nil if the value is nil" do
      field = Marten::Schema::Field::DateTime.new("test_field")
      field.deserialize(nil).should be_nil
    end

    it "returns nil if the passed value is an empty value" do
      field = Marten::Schema::Field::DateTime.new("test_field")
      field.deserialize("").should be_nil
    end

    it "returns a time object if the value is a time object" do
      time = Time.local

      field = Marten::Schema::Field::DateTime.new("test_field")
      field.deserialize(time).should eq time
    end

    it "returns a time object in the project time zone if the value is in another timezone" do
      est_time_zone = Time::Location.load("EST")

      with_overridden_setting("time_zone", est_time_zone) do
        time = Time.local.in(Time::Location.load("Europe/Paris"))
        expected_time = time.in(est_time_zone)

        field = Marten::Schema::Field::DateTime.new("test_field")
        field.deserialize(time).should eq expected_time
        field.deserialize(time).not_nil!.location.should eq est_time_zone
      end
    end

    it "returns a time object in the project time zone if the value is a string in the ISO 8601 format" do
      field = Marten::Schema::Field::DateTime.new("test_field")
      field.deserialize("2022-03-18T22:26:05Z").should eq Time.parse_iso8601("2022-03-18T22:26:05Z")
      field.deserialize("2022-03-18T22:26:05Z").not_nil!.location.should eq Marten.settings.time_zone
    end

    it "returns a time object in the project time zone if the value is a string with a supported format" do
      supported_formats = [
        "%Y-%m-%d %H:%M:%S",
        "%Y-%m-%d %H:%M:%S.%f",
        "%Y-%m-%d %H:%M",
        "%m/%d/%Y %H:%M:%S",
        "%m/%d/%Y %H:%M:%S.%f",
        "%m/%d/%Y %H:%M",
      ]

      supported_formats.each do |format|
        time = Time.local(Marten.settings.time_zone)

        field = Marten::Schema::Field::DateTime.new("test_field")
        field.deserialize(time.to_s(format)).should eq Time.parse(time.to_s(format), format, Marten.settings.time_zone)
        field.deserialize(time.to_s(format)).not_nil!.location.should eq Marten.settings.time_zone
      end
    end

    it "returns a time object in the project time zone for valid JSON objects" do
      supported_formats = [
        "%Y-%m-%d %H:%M:%S",
        "%Y-%m-%d %H:%M:%S.%f",
        "%Y-%m-%d %H:%M",
        "%m/%d/%Y %H:%M:%S",
        "%m/%d/%Y %H:%M:%S.%f",
        "%m/%d/%Y %H:%M",
      ]

      supported_formats.each do |format|
        time = Time.local(Marten.settings.time_zone)

        field = Marten::Schema::Field::DateTime.new("test_field")
        field.deserialize(JSON.parse(%{"#{time.to_s(format)}"})).should eq(
          Time.parse(time.to_s(format), format, Marten.settings.time_zone)
        )
        field.deserialize(JSON.parse(%{"#{time.to_s(format)}"})).not_nil!.location.should eq Marten.settings.time_zone
      end
    end

    it "falls back to the default input format if the value is not in a localized format" do
      format = "%Y ~ %m ~ %d ~ %H ~ %M ~ %S"

      with_overridden_setting("date_time_input_formats", [format]) do
        time = Time.local(Marten.settings.time_zone)

        field = Marten::Schema::Field::DateTime.new("test_field")
        field.deserialize(time.to_s(format)).should eq Time.parse(time.to_s(format), format, Marten.settings.time_zone)
        field.deserialize(time.to_s(format)).not_nil!.location.should eq Marten.settings.time_zone
      end
    end

    it "raises if the passed value has an unexpected type" do
      field = Marten::Schema::Field::DateTime.new("test_field")
      expect_raises(Marten::Schema::Errors::UnexpectedFieldValue) { field.deserialize(true) }
    end

    it "raises if the passed value is a string that can't be parsed properly" do
      field = Marten::Schema::Field::DateTime.new("test_field")
      expect_raises(Marten::Schema::Errors::UnexpectedFieldValue) { field.deserialize("this is bad") }
    end
  end

  describe "#serialize" do
    it "returns the string version of the passed value" do
      time = Time.local(Marten.settings.time_zone)

      field = Marten::Schema::Field::DateTime.new("test_field")
      field.serialize(time).should eq time.to_s
    end

    it "returns nil if the passed value is nil" do
      field = Marten::Schema::Field::DateTime.new("test_field")
      field.serialize(nil).should be_nil
    end
  end

  describe "#perform_validation" do
    it "validates a value that is in the ISO 8601 format" do
      schema = Marten::Schema::Field::DateTimeSpec::TestSchema.new(
        Marten::HTTP::Params::Data{"test_field" => ["2022-03-18T22:26:05Z"]}
      )

      field = Marten::Schema::Field::DateTime.new("test_field")
      field.perform_validation(schema)

      schema.errors.should be_empty
    end

    it "validates a value that has the right format" do
      supported_formats = [
        "%Y-%m-%d %H:%M:%S",
        "%Y-%m-%d %H:%M:%S.%f",
        "%Y-%m-%d %H:%M",
        "%m/%d/%Y %H:%M:%S",
        "%m/%d/%Y %H:%M:%S.%f",
        "%m/%d/%Y %H:%M",
      ]

      supported_formats.each do |format|
        time = Time.local(Marten.settings.time_zone)

        schema = Marten::Schema::Field::DateTimeSpec::TestSchema.new(
          Marten::HTTP::Params::Data{"test_field" => [time.to_s(format)]}
        )

        field = Marten::Schema::Field::DateTime.new("test_field")
        field.perform_validation(schema)

        schema.errors.should be_empty
      end
    end

    it "does not validate a value that is not a date time" do
      schema = Marten::Schema::Field::DateTimeSpec::TestSchema.new(
        Marten::HTTP::Params::Data{"test_field" => ["this is bad"]}
      )

      field = Marten::Schema::Field::DateTime.new("test_field")
      field.perform_validation(schema)

      schema.errors.size.should eq 1
      schema.errors.first.field.should eq "test_field"
      schema.errors.first.message.should eq I18n.t("marten.schema.field.date_time.errors.invalid")
    end
  end
end

module Marten::Schema::Field::DateTimeSpec
  class TestSchema < Marten::Schema
    field :test_field, :date_time
  end
end
