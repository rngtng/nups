l = Tolk::Locale.where(:name => 'en').first
t = Tolk::Phrase.create(:key => 'menu.charts')
l.translations.create(:phrase => t, :text => 'Charts')
t = Tolk::Phrase.create(:key => 'ctrl.save')
l.translations.create(:phrase => t, :text => 'save')
t = Tolk::Phrase.create(:key => 'newsletters.all')
l.translations.create(:phrase => t, :text => 'All Recipient')
t = Tolk::Phrase.create(:key => 'newsletters.user')
l.translations.create(:phrase => t, :text => 'Recipients')
t = Tolk::Phrase.create(:key => 'newsletters.users')
l.translations.create(:phrase => t, :text => 'Recipient')
t = Tolk::Phrase.create(:key => 'newsletters.ctrl.clone')
l.translations.create(:phrase => t, :text => 'clone')
t = Tolk::Phrase.create(:key => 'newsletters.menu')
l.translations.create(:phrase => t, :text => 'menu')
t = Tolk::Phrase.create(:key => 'recipients.confirm.delete')
l.translations.create(:phrase => t, :text => 'delete')
t = Tolk::Phrase.create(:key => 'recipients.new.ctrl.check')
l.translations.create(:phrase => t, :text => 'check')
t = Tolk::Phrase.create(:key => 'recipients.new.ctrl.valid_import')
l.translations.create(:phrase => t, :text => 'import')
t = Tolk::Phrase.create(:key => 'recipients.new.explanation')
l.translations.create(:phrase => t, :text => 'Expl. TODO')
t = Tolk::Phrase.create(:key => 'recipients.new.invalid_recipients')
l.translations.create(:phrase => t, :text => 'invalid recipients')
t = Tolk::Phrase.create(:key => 'recipients.new.valid_recipients')
l.translations.create(:phrase => t, :text => 'valid recipients')
t = Tolk::Phrase.create(:key => 'recipients.menu.delete')
l.translations.create(:phrase => t, :text => 'delete')
t = Tolk::Phrase.create(:key => 'recipients.delete.ctrl.check')
l.translations.create(:phrase => t, :text => 'check')
t = Tolk::Phrase.create(:key => 'recipients.delete.ctrl.confirm_delete')
l.translations.create(:phrase => t, :text => 'confirm delete')
t = Tolk::Phrase.create(:key => 'recipients.delete.ctrl.valid_delete')
l.translations.create(:phrase => t, :text => 'valid delete')
t = Tolk::Phrase.create(:key => 'recipients.delete.explanation')
l.translations.create(:phrase => t, :text => 'Expl. TODO')
t = Tolk::Phrase.create(:key => 'recipients.delete.invalid_recipients')
l.translations.create(:phrase => t, :text => 'invalid recipients')
t = Tolk::Phrase.create(:key => 'recipients.delete.title')
l.translations.create(:phrase => t, :text => 'Delete Recipients')
t = Tolk::Phrase.create(:key => 'recipients.delete.valid_recipients')
l.translations.create(:phrase => t, :text => 'valid recipients')
t = Tolk::Phrase.create(:key => 'recipients.title')
l.translations.create(:phrase => t, :text => 'Recipients')
t = Tolk::Phrase.create(:key => 'charts.title')
l.translations.create(:phrase => t, :text => 'Charts')