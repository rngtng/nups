# Welcome to NUPS

## resources

  * Overview of best plugins: http://ruby-toolbox.com/
  * [Devise](http://github.com/plataformatec/devise) -> `rails generate devise_install`
  * Test SMTP lockally: http://mocksmtpapp.com/
  * Spinners:
      http://www.andrewdavidson.com/articles/spinning-wait-icons/
      http://mentalized.net/activity-indicators/

## TODO
  * try send grids:
    http://stackoverflow.com/questions/4798141/sendgrid-vs-postmark-vs-amazon-ses-and-other-email-smtp-api-providers
  * check: stop while in pre_sending??
  * check: error when creating send_outs
  * chart when people read
  * remove  mode/status/last_send_id from newsletter
  * order DESC
  * heighlight reciever with bounce count, set option to disable
  * translation (gender)
     - https://github.com/stevo/i18n_translation_spawner
     - https://github.com/lardawge/rails-i18nterface
     - https://github.com/berk/tr8n
     - https://github.com/amberbit/translator
     - https://github.com/grosser/translation_db_engine
     - https://github.com/mconf/translate
     - http://railscasts.com/episodes/256-i18n-backends
     - http://github.com/panva/tolk
     - https://github.com/rkyrychuk/tolk
     - http://guides.rubyonrails.org/i18n.html
  * add better migration
  * test coffeescript
  * animate sendout & test gif icons
  * check: http://isnotspam.com
  * test premailer
  * add index to recipients
  * bounce only when 5.X code
  * bounce cleanup
  * mv send_out textfield into string? (speed up)

## DONE
 * check what happens if a single sendout fails within a batch
 * add better fixtures: factory_girl
 * newsletter stats: total/percent send/fail/bounces/read count
   ->   * add infos to newsletter to see total read/bounces
 * history stats
     recipient growth
     newsletter read/bounce growth
     sending time/speed
  * remove error_message recipeint -> move to send_out
  * change update_newsletter to json
  * reactivate deleted users
  * send test email to current_user.email
  * newsletter unsubscribe by email
  * autodetect URLS
  * unsubscribe ->
    header:  http://www.list-unsubscribe.com/
  * recipients: overflow for user name + email
  * remove error_code from send_out
  * errors_count + errors message
  * hidden image to register if nl was read *test*
  * read NL on website *test*
  * read count to recipient *update when read* *test*
  * update bounce counters:
     -> only counter bounces younger than last update time -> bounces_count_updated_at
     -> resque task?
     -> on bounce create? if user available?
  * update deliver counters:
      -> after send?
  * fix receiver edit
  * recipients overlay with list of sendouts (details -> when which newsletter was send)
  * hide deleted receiver
  * sort receiver column, indicate sorting *test*
  * receiver paginate ajax
  * pretty time span
  * add user total count on top
  * update deliverd_startet_at_ from youngest sendout
  * scheduling
  * recipients import/export
  * Newsletter delete ajax
  * search pagination, show total amount
  * attachment upload
  * new newsletter scroll
  * reload after recp import
  * open new newsletter in window
  * recipients
  * in place editing (improvement see rails cast)
  * fix travis setup: http://about.travis-ci.org/docs/user/build-configuration/
  * progress bar update time
  * resque status: http://github.com/quirkey/resque-status

## Resque Startup:
  * rake resque:workers:start

## Mail
  http://www.techsoup.org/learningcenter/internet/page5052.cfm
  http://www.sitepoint.com/forums/showthread.php?571536-Building-a-newsletter-not-getting-listed-as-spam
  http://gettingattention.org/articles/160/email-enewsletters/nonprofit-email-newsletter-success.html

## Builder
[![Build Status](https://secure.travis-ci.org/rngtng/nups.png)](http://travis-ci.org/rngtng/nups)
