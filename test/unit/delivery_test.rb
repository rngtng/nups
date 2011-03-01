require 'test_helper'

class DeliveryTest < ActiveSupport::TestCase
  
  setup do
    @newsletter = newsletters(:biff_newsletter)
    @delivery   = @newsletter.deliveries.create!
  end
  
  test "don't allow multiple instances of status 'created'" do
    assert @newsletter.create!.new_record?
  end

  test "don't allow multiple instances of status 'created' and 'running'" do
    @newsletter = newsletters(:biff_newsletter)
    delivery = @newsletter.deliveries.create!
    @newsletter.update_attributes(:status => 'running')
    assert @newsletter.create!
    .new_record?
  end

  test "allow multiple instances of status 'created' and 'stopped'" do
    @newsletter = newsletters(:biff_newsletter)
    @newsletter.create!
    @newsletter.update_attributes(:status => 'stopped')
    assert @newsletter.create!.new_record?
  end

  test "allow multiple instances of status 'created' and 'finished'" do
    @newsletter = newsletters(:biff_newsletter)
    @newsletter.create!
    @newsletter.update_attributes(:status => 'finished')
    assert @newsletter.create!.new_record?
  end

end

