class TestDelivery < Delivery

  def recipients_all
    self.newsletter.account.test_recipients
  end
end