Ads On Rails
================

The application is a simple demo about advertisement management systems for both google adwords and facebook ads which is built base on google-api-ads-ruby support by Google(reference: [https://github.com/googleads/google-api-ads-ruby/tree/master/adwords_api/examples/adwords_on_rails](https://github.com/googleads/google-api-ads-ruby/tree/master/adwords_api/examples/adwords_on_rails)) and Zuck (reference: [https://github.com/moviepilot/zuck](https://github.com/moviepilot/zuck))


How do I get started?
---------------------

1. Make sure you have Ruby 2.1 or later installed:

    ```$ ruby -v```
    ruby 2.2.2p95 (2015-04-13 revision 50295) [x86_64-linux]

2. Clone the application to your directory
3. Change to the application root:

    ```cd ads-on-rails```
4. Install all required dependencies using bundle:

    ```$ bundle install```

6. Initialize default local schema:

    $ rake db:migrate

7. Configure AdWords API settings:

    $ vi config/adwords_api.yml

8. Start the server:

    $ script/rails server

You should be able to access the application now by pointing your browser to:

    http://localhost:3000


Using the application
---------------------

In order to access AdWords data the application needs to be granted access by a
logged in user. You will be automatically redirected to a page with login prompt
when not yet authorized.

To grant access, click the 'Proceed' link. Make sure you are on the Google login
page, log in with your AdWords account credentials and select 'Grant access'.

Note: Granting access to the application will only allow access to the AdWords
data for the account. Other services will not be accessible.

Once logged in you can retrieve the accounts list, select an account and browse
the campaigns list or download a report with the corresponding menu items.


Configuring the Ruby AdWords API library
----------------------------------------

To be able to use the AdWords API there are a few parameters that need to be
specified. The configuration file is located under the 'config' directory and
named adwords_api.yml.

For details regarding configuration directive please refer to the [library
README](https://github.com/googleads/google-api-ads-ruby/blob/master/adwords_api/README.md).


Production accounts
-------------------

This demo is capable of accessing production accounts. Although the app doesn't
perform any mutate opertions, it's best to be careful especially if modifying it
to include additional functionality.


Where do I submit bug reports and feature requests?
---------------------------------------------------

Bug reports and feature requests can be submitted at:

    https://github.com/googleads/google-api-ads-ruby/issues

Also please feel free to ask questions and discuss the application on forums:

    https://groups.google.com/forum/#!forum/adwords-api

Make sure to subscribe to our Google Plus page for API change announcements and
other news:

    https://plus.google.com/+GoogleAdsDevelopers

Contacts:
---------

Authors:

    Danial Klimkin
    Michael Cloonan
