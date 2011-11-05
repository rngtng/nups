# Welcome to NUPS

## resources

  * Overview of best plugins: http://ruby-toolbox.com/
  * [Devise](http://github.com/plataformatec/devise) -> `rails generate devise_install`
  * Test SMPT lockally: http://mocksmtpapp.com/
  *  spinners:
  http://www.andrewdavidson.com/articles/spinning-wait-icons/
  http://mentalized.net/activity-indicators/
  * reques test: http://github.com/justinweiss/resque_unit

## TODO
  * update bounce counters:
     -> only counter bounces younger than last update time -> bounces_count_updated_at
     -> resqu task?
     -> on bounce create? if user available?
  * update deliver counters:
    -> after send?
  * progress bar update time
  * translation
  * resque status: http://github.com/quirkey/resque-status
  * errors_count + erros messaage
  * filter valid/invalid
  * details -> when which newsletter was send
  * recipients: overflow for user name + email
  * unsubscribe ->
  * fix travis setup: http://about.travis-ci.org/docs/user/build-configuration/

## DONE

  * scheduling
  * recipients import/export
  * Newsletter delete ajax
  * search pagination, show total amount
  * attachment upload
  * new newsletter scroll
  * reload after recp import
  * open new newsletter in window
  * recipients
  * in place editing


## Resque Startup:

  1. redis-server
  2. COUNT=1 QUEUE=* rake resque:workers
  
## Builder
[![Build Status](https://secure.travis-ci.org/rngtng/nups.png)](http://travis-ci.org/rngtng/nups)
