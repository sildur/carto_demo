# README

## Prerequisites

* RVM

## Set up
```shell script
git clone git@github.com:sildur/carto_demo.git
cd carto_demo
bundle install
rake db:setup
```

# Running
```shell script
rails s
```

# Running tests
```shell script
bundle exec rspec
```
## TODO
* Do not recommend an outdoors activity on a rainy day

  We could check an external API like https://openweathermap.org/api, and
  given the user coordinates and time range, filter activities by only 
  showing indoor activities if the weather is going to be rainy for
  the time range.
* Support getting information about activities in multiple cities
  
  We could add a latitude/longitude parameter to the recommended endpoint
  and maybe a radius and filter activities in that radius.
* Extend the recommendation API to fill the given time range with multiple activities

   That would require find activities for the time range that do not overlap. But 
   we would also have to require a transportation method parameter, so we
   can calculate the time it would take to move from location to location.

## Developer notes
* The code has been checked with the rubocop gem
* The testing suite is rspec
* Code coverage is checked with the simplecov gem. Code coverage is 100%. You 
can find the coverage report on coverage/index.html
* The project uses the gem annotate to automatically annotate the models with 
schema info
