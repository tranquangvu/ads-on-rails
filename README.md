Ads On Rails
================

The application is a simple demo about advertisement management systems for both google adwords and facebook ads which is built base on google-api-ads-ruby support by Google (reference: [https://github.com/googleads/google-api-ads-ruby/tree/master/adwords_api/examples/adwords_on_rails](https://github.com/googleads/google-api-ads-ruby/tree/master/adwords_api/examples/adwords_on_rails)) and Zuck (reference: [https://github.com/moviepilot/zuck](https://github.com/moviepilot/zuck))


Get started?
---------------------

1. Make sure you have Ruby 2.1 or later installed:

    ```$ ruby -v```
    ruby 2.2.2p95 (2015-04-13 revision 50295) [x86_64-linux]

2. Clone the application to your directory
3. Change to the application root:

    ```cd ads-on-rails```
4. Install all required dependencies using bundle:

    ```$ bundle install```

5. Initialize default local schema:

    ```$ rake db:migrate```

6. Configure AdWords API settings:

    ```$ vi config/adwords_api.yml```

8. Start the server:

    ```$ rails server```
