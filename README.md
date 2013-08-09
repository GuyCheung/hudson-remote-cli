[![Build Status](https://travis-ci.org/GuyCheung/hudson-remote-cli.png)](https://travis-ci.org/GuyCheung/hudson-remote-cli.png)

# Hudson Remote Cli

hudson-remote-cli is ruby library to talk to Hudson's json remote access api

## Installation

Add this line to your application's Gemfile:

    gem install hudson-remote-cli

## Configuration

```ruby
require 'hudson-remote-cli'

# Manual Configuration
Hudson[:url] = 'http://localhost:8080'
Hudson[:user] = 'hudson'
Hudson[:password] = 'password'
```

## Usage

### Information for Hudson
```ruby
# get all jobs
Hudson.jobs

# load statistics
Hudson.overallLoad

# get all infomation for hudson
Hudson.api

# just get job name and colors.
# For more of this see:_Controlling the amount of data you fetch_ in hudson help
# All api method can use like this
Hudson.api('jobs[name, color]')

# when you request the _api_ method, we'll cache the data default.
# you can specified the second param as true to clean the cache
Hudson.api('jobs[name, color]', true)
```

### Information for Build Queue
```ruby
# get build queue job names
Hudson::BuildQueue.list

# get full information of build queue
Hudson::BuildQueuq.api
```

### Create a job
```ruby
job = Hudson::Job.create('job_name', 'config.xml local path')
```

### Actions and Informatons on job
```ruby
# load existing job
j = Hudson::Job.new('job_name')

# enable the job
j.enable

# disable the job
j.disable

# is the job enable?
j.buildable?

# start a build
j.build

# start a build with params
j.build({'key1' => 'value1', 'key2' => 'value2', ...})

# is the job building
j.active?

# wait the job building complete
j.wait_for_build

# start a build and wait for it finish, also worked with params
j.build!

# description of the job
j.description

# set description of the job
j.description = 'some description'

# update the job
j.update('config.xml local path')

# delete the job
j.delete

# job name
j.name

# all information
j.api

# last build number
j.last_build

# last success build number
j.last_success_build
```

### Information of a build
```ruby
# get information on latest build
b = Hudson::Build.new('job_name')

# get information on particular build number
b = Hudson::Build.new('job_name', 142)

# get all informations of the build
b.api

# get the result of this build
b.result

# get commit revisions in this build
b.revisions

# build start time
b.start_time

# build end time
b.end_time

# build log
b.console
```

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Added some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
