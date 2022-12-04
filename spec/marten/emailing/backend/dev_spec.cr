require "./spec_helper"

describe Marten::Emailing::Backend::Dev do
  describe "#deliver" do
    it "collects the delivered email by default" do
      email = Marten::Emailing::Backend::DevSpec::TestEmail.new
      backend = Marten::Emailing::Backend::Dev.new

      backend.deliver(email)

      backend.delivered_emails.includes?(email).should be_true
    end

    it "does not collect the delivered email if this capability is deactivated" do
      email = Marten::Emailing::Backend::DevSpec::TestEmail.new
      backend = Marten::Emailing::Backend::Dev.new(collect_emails: false)

      backend.deliver(email)

      backend.delivered_emails.should be_empty
    end

    it "does not output anything by default" do
      stdout = IO::Memory.new

      email = Marten::Emailing::Backend::DevSpec::TestEmail.new
      backend = Marten::Emailing::Backend::Dev.new(stdout: stdout)

      backend.deliver(email)

      stdout.rewind
      stdout.gets_to_end.should be_empty
    end

    it "outputs a simple email as expected if this capability is activated" do
      stdout = IO::Memory.new

      email = Marten::Emailing::Backend::DevSpec::TestEmail.new
      backend = Marten::Emailing::Backend::Dev.new(print_emails: true, stdout: stdout)

      backend.deliver(email)

      stdout.rewind
      stdout.gets_to_end.should eq(
        <<-OUTPUT
        From: webmaster@localhost
        To: test@example.com
        Subject: Hello World!
        ---------- TEXT ----------
        Text body
        ---------- HTML ----------
        HTML body
        OUTPUT
      )
    end

    it "outputs an email with CC addresses as expected if this capability is activated" do
      stdout = IO::Memory.new

      email = Marten::Emailing::Backend::DevSpec::TestEmailWithCc.new
      backend = Marten::Emailing::Backend::Dev.new(print_emails: true, stdout: stdout)

      backend.deliver(email)

      stdout.rewind
      stdout.gets_to_end.should eq(
        <<-OUTPUT
        From: webmaster@localhost
        To: test@example.com
        CC: cc1@example.com, cc2@example.com
        Subject: Hello World!
        OUTPUT
      )
    end

    it "outputs an email with BCC addresses as expected if this capability is activated" do
      stdout = IO::Memory.new

      email = Marten::Emailing::Backend::DevSpec::TestEmailWithBcc.new
      backend = Marten::Emailing::Backend::Dev.new(print_emails: true, stdout: stdout)

      backend.deliver(email)

      stdout.rewind
      stdout.gets_to_end.should eq(
        <<-OUTPUT
        From: webmaster@localhost
        To: test@example.com
        BCC: bcc1@example.com, bcc2@example.com
        Subject: Hello World!
        OUTPUT
      )
    end

    it "outputs an email with headers as expected if this capability is activated" do
      stdout = IO::Memory.new

      email = Marten::Emailing::Backend::DevSpec::TestEmailWithHeaders.new
      backend = Marten::Emailing::Backend::Dev.new(print_emails: true, stdout: stdout)

      backend.deliver(email)

      stdout.rewind
      stdout.gets_to_end.should eq(
        <<-OUTPUT
        From: webmaster@localhost
        To: test@example.com
        Subject: Hello World!
        Headers: {"foo" => "bar"}
        OUTPUT
      )
    end
  end
end

module Marten::Emailing::Backend::DevSpec
  class TestEmail < Marten::Email
    subject "Hello World!"
    to "test@example.com"

    def html_body
      "HTML body"
    end

    def text_body
      "Text body"
    end
  end

  class TestEmailWithCc < Marten::Email
    subject "Hello World!"
    to "test@example.com"

    cc ["cc1@example.com", "cc2@example.com"]
  end

  class TestEmailWithBcc < Marten::Email
    subject "Hello World!"
    to "test@example.com"

    bcc ["bcc1@example.com", "bcc2@example.com"]
  end

  class TestEmailWithHeaders < Marten::Email
    subject "Hello World!"
    to "test@example.com"

    def headers
      {"foo" => "bar"}
    end
  end
end
