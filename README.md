# Welcome to NUPS

## resources

  * Overview of best plugins: http://ruby-toolbox.com/
  * [Devise](http://github.com/plataformatec/devise) -> `rails generate devise_install`
  * Test SMTP lockally: http://mocksmtpapp.com/
  * Spinners:
      http://www.andrewdavidson.com/articles/spinning-wait-icons/
      http://mentalized.net/activity-indicators/

## TODO
  * introduce foreign key for send_outs? -> auto delete test sendouts
  * remove  mode/status/last_send_id from newsletter
  * order DESC
  * heighlight reciever with bounce count, set option to disable
  * translation (gender)
  * add better migration
  * test coffeescript
  * animate sendout & test gif icons
  * move to better fixutres: factory_girl, machinist??
    http://fabricationgem.org/#!extras
  * check: http://isnotspam.com
  * test premailer
  * add index to recipients
  * bounce only when 5.X code
  * bounce cleanup
  * check what happens if a single sendout fails within a batch
  * mv send_out textfield into string? (speed up)

## DONE
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

  1. redis-server
  2. COUNT=1 QUEUE=* rake resque:workers

## Mail
  http://www.techsoup.org/learningcenter/internet/page5052.cfm
  http://www.sitepoint.com/forums/showthread.php?571536-Building-a-newsletter-not-getting-listed-as-spam
  http://gettingattention.org/articles/160/email-enewsletters/nonprofit-email-newsletter-success.html

## Builder
[![Build Status](https://secure.travis-ci.org/rngtng/nups.png)](http://travis-ci.org/rngtng/nups)
