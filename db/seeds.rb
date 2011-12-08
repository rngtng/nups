# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
User.delete_all
user = User.new(username:'admin', email:'admin@localhost.de')
user.password = user.password_confirmation = 'admin'
user.admin = true
user.save!

user2 = User.new(username:'test', email:'test@localhost.de')
user2.password = user.password_confirmation = 'test'
user2.save!

Domain.delete_all
user2.domains.create(name:"germanstockpromoters.de", number:1084641, username:"bschulze", password:"testets")

Account.delete_all
account = Account.create(name:"Test", from:"test@localhost.de", user:user, subject:"Test", has_html:true, has_text:true, has_attachments:true, has_scheduling:true)

newsletters = {}
Newsletter.delete_all
Newsletter.new.state_paths.to_states.each do |state|
  newsletters[state] = Newsletter.create(subject:"Test in #{state}", content:"Test", account:account, state:state.to_s)
end

newsletters[:sending].update_attributes(deliveries_count:20, recipients_count:100)
newsletters[:stopping].update_attributes(deliveries_count:60, recipients_count:100)
newsletters[:stopped].update_attributes(deliveries_count:80, recipients_count:100)
newsletters[:finished].update_attributes(deliveries_count:100, recipients_count:100)

Recipient.delete_all
100.times do |index|
  Recipient.create(email:"test-#{index}@localhost.de", account:account)
end

