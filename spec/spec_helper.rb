require 'hudson-remote-cli'
require 'rspec'

Hudson[:url] = 'http://localhost:8235/hudson'
Hudson[:user] = 'test'
Hudson[:password] = 'test'
