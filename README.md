# Authk

Authk is intended to be used as a central authentication point for multiple satellite applications (e.g. Google Engine). A registered client can hold multiple applications and each application has multiple users.

## Setup environment

In order to get things going, you'll want some ruby version manager ([rbenv](https://github.com/sstephenson/rbenv), [rvm](http://rvm.io),  etc)
Then, install ruby 2.1.3, and through that bundler
For instance, with rbebnv

```bash
rbenv install 2.1.3
rbenv local 2.1.3
gem install bundler
```

Running the following commands is a quick and dirty way to get everything up and running:

```bash
bundle install
foreman start -f ./Procfile.dev
```

## Running tests

To run the entire test suite:

```bash
rspec ./specs
```

## Debugging

There's an irb console that automatically loads all app files for you to play around.

```bash
rake console
```

## API Documentation

You can update the documentation page by running:

```bash
rake documentation:generate
```

## Application structure

### API

Contain the API delivery mechanism files (e.g. handling JSON input and output).

### Business

The files under `business` contain all the models and actions that pertain the workings of this app.

### Documentation

Holds all the API documentation pages. They're automatically generated based on Grape's endpoint descriptions.
