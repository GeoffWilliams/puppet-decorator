# decorator

#### Table of Contents

1. [Description](#description)
1. [Setup - The basics of getting started with decorator](#setup)
    * [What decorator affects](#what-decorator-affects)
    * [Setup requirements](#setup-requirements)
    * [Beginning with decorator](#beginning-with-decorator)
1. [Usage - Configuration options and additional functionality](#usage)
1. [Reference - An under-the-hood peek at what the module is doing and how](#reference)
1. [Limitations - OS compatibility, etc.](#limitations)
1. [Development - Guide for contributing to the module](#development)

## Description

Start with a one- or two-sentence summary of what the module does and/or what
problem it solves. This is your 30-second elevator pitch for your module.
Consider including OS/Puppet version it works with.

You can give more descriptive information in a second paragraph. This paragraph
should answer the questions: "What does this module *do*?" and "Why would I use
it?" If your module has a range of functionality (installation, configuration,
management, etc.), this is the time to mention it.

## Setup

### What decorator affects **OPTIONAL**

If it's obvious what your module touches, you can skip this section. For
example, folks can probably figure out that your mysql_instance module affects
their MySQL instances.

If there's more that they should know about, though, this is the place to mention:

* A list of files, packages, services, or operations that the module will alter,
  impact, or execute.
* Dependencies that your module automatically installs.
* Warnings or other important notices.

### Setup Requirements **OPTIONAL**

If your module requires anything extra before setting up (pluginsync enabled,
etc.), mention it here.

If your most recent release breaks compatibility or requires particular steps
for upgrading, you might want to include an additional "Upgrading" section
here.

### Beginning with decorator

The very basic steps needed for a user to get the module up and running. This
can include setup steps, if necessary, or it can be an example of the most
basic use of the module.

## Usage

This section is where you describe how to customize, configure, and do the
fancy stuff with your module here. It's especially helpful if you include usage
examples and code samples for doing things with your module.

## Reference
### `only_before_sync`
Custom type and provider to allow running resources before another resource is synced

## Limitations
* Not supported by Puppet

## Development
Pull Requests welcome

## Testing
This project is complete with acceptance tests written using:
* [Test Kitchen](http://kitchen.ci)
* [Kitchen-Puppet](https://github.com/neillturner/kitchen-puppet)
* [Bats](https://github.com/sstephenson/bats)

Tests currently use Docker so you will need this setup on the machine you are testing from.

DO NOT RUN TESTS FROM A PUPPET MASTER!

To run them tests, first prepare your system:
```shell
bundle install
```

You may then prepare a test system by running:
```shell
bundle exec kitchen create
```

Puppet will be run every time you execute:
```shell
bundle exec kitchen converge
```

The results of running puppet can then be captured by:
```shell
bundle exec kitchen verify
```

It is suggested to have your CI server execute these tests before allowing code
to be published to the puppet master

