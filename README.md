# Authk

Authk is intended to be used as a central authentication point for multiple satellite applications (e.g. Google Engine). A registered client can hold multiple applications and each application has multiple users.

## How does it work?

[CLIENT]

Before making the API call, combine the HTTP method (GET, POST, etc), the utc timestamp of the request, with the string representation of your parameters. Hash (HMAC-SHA1) the blob of data (from Step #1) with your private key assigned to you by the system. Send the server the following data in the header of your request:
* Your app Public Key assigned to you by the system. This is a public value that anyone (even evil masterminds can know and you don’t mind). It is just a way for the system to know WHO is sending the request, not if it should trust the sender or not (we figure that out based on the HMAC).
* Send the timestamp, in utc format, of the request.
* Send the HMAC (hash) you generated.
* Send all the data (parameters and values) you were planning on sending anyway. Probably unencrypted if they are harmless values, like “mode=start&number=4&order=desc” or other operating nonsense. If the values are private, you’ll need to encrypt them.

[SERVER]

Receive all the data from the client. Compare the current server’s timestamp to the timestamp the client sent. Make sure the difference between the two timestamps it within an acceptable time limit (currently 1 minute) to hinder replay attacks. Using the user-identifying data sent along with the request (i.e. Public Key) look the user up in the DB and load their private key. Re-combine the same data in the same way that the client did. Then hash (generate HMAC) the data blob using the app private key. Compare the hash calculated on the server, with the hash the client sent; if they match, then the client is considered legit, so process the command. Otherwise reject the command!

SUPER-REMINDER: Your private key should never be transferred over the wire, it is just used to generate the HMAC, the server looks the private key back up itself and recalculates its own HMAC. The public key is the only key that goes across the wire to identify the user making the call; It is OK if a nefarious evil-doer gets that value, because it doesn’t imply his messages will be trusted. They still have to be hashed with the private key and hashed in the same manner both the client and server are using (e.g. prefix, postfix, multiple times, etc.)

### Example

A request to authenticate an user for a given app would provide:

GET /api/users/authenticate

Headers:
{
  "Timestamp" => "2014-10-29 23:15:35 UTC",
  "Publickey" => "dbd45b1f22532beb8c9a55531a94b67a6d2960ef1c586f384de1c997657ae348",
  "Hmac" => "ce75fcb8d688e235761027bef2055098b061c664"
}

Parameters:
{
  "email" => "kacie_runolfon@white.com",
  "password" => "1029384756"
}

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

### References

http://www.thebuzzmedia.com/designing-a-secure-rest-api-without-oauth-authentication/
