require "./spec_helper"

describe Marten::Template::Condition do
  describe "#expression" do
    it "returns the right token for a given right binding power" do
      condition = Marten::Template::Condition.new(["var1", "||", "var2"])
      token = condition.expression(0)
      token.should be_a Marten::Template::Condition::Token::Operator::Or
    end
  end

  describe "#parse" do
    it "is able to process an or expression" do
      condition = Marten::Template::Condition.new(["var1", "||", "var2"])
      token = condition.parse

      token.eval(Marten::Template::Context{"var1" => false, "var2" => false}).truthy?.should be_false
      token.eval(Marten::Template::Context{"var1" => false, "var2" => true}).truthy?.should be_true
      token.eval(Marten::Template::Context{"var1" => true, "var2" => false}).truthy?.should be_true
      token.eval(Marten::Template::Context{"var1" => true, "var2" => true}).truthy?.should be_true
    end

    it "is able to process an an expression" do
      condition = Marten::Template::Condition.new(["var1", "&&", "var2"])
      token = condition.parse

      token.eval(Marten::Template::Context{"var1" => false, "var2" => false}).truthy?.should be_false
      token.eval(Marten::Template::Context{"var1" => false, "var2" => true}).truthy?.should be_false
      token.eval(Marten::Template::Context{"var1" => true, "var2" => false}).truthy?.should be_false
      token.eval(Marten::Template::Context{"var1" => true, "var2" => true}).truthy?.should be_true
    end
  end
end