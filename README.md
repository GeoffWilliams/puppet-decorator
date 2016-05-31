[![Build Status](https://travis-ci.org/GeoffWilliams/puppet-only_before_sync.svg?branch=master)](https://travis-ci.org/GeoffWilliams/puppet-only_before_sync)
# only_before_sync

#### Table of Contents

1. [Description](#description)
1. [Setup - The basics of getting started with only_before_sync](#setup)
    * [What only_before_sync affects](#what-only_before_sync-affects)
    * [Setup requirements](#setup-requirements)
    * [Beginning with only_before_sync](#beginning-with-only_before_sync)
1. [Usage - Configuration options and additional functionality](#usage)
1. [Reference - An under-the-hood peek at what the module is doing and how](#reference)
1. [Limitations - OS compatibility, etc.](#limitations)
1. [Development - Guide for contributing to the module](#development)

## Description
only_before_sync allows you to designate specific resources to run ONLY when a resources is scheduled to be synced (run).

Practically, this module lends itself to tasks such as running scripts _before_ a particular package is installed or upgraded.

### How it works
A regular puppet resource will normally self-determine if it needs to sync (run) and will then perform the required actions as a single step.

This module works by front-loading this process with a test to see if the resource needs to sync and then enables and executes the conditional resources.

Each instance of this resource needs to be configured with:
* `resource` - the main resource that we are testing against
* `before_sync` - Puppet resources to enable and process if `resource` needs sync.  These must each be put in `noop` mode.  If this module determines that `resource` will sync, they will be enabled and then processed naturally as part of the Puppet run

Graphically, the following procedure looks like this:

```
start                                                         c   c   o
  |                                                           a   o   n
  V                                                           t   m
validate parameters and catalog                               a   p   m
  |                                                           l   i   a
  V                                                           g   l   s
reorder catalog resources                                         e   t
  |                                                                   e
  |                                                                   r
  |
..|.............................................................................
  |
catalog produced and control passed to agent
  |
..|.............................................................................
  V
<resource needs sync> --------------------------------        t   m
  | yes                                              |        h   o
  V                                                  |        i   d
turn off noop mode for before_sync resources         |        s   u
  |                                                  |            l
  |                                                  |            e
  |                                                  |
..|..................................................|..........................
  V                                                  |      
agent naturally processes before_sync resources <-----        y   c
  |                                                           o   o
agent naturally processes main resource                       u   d
    |                                                         r   e
    |
....|...........................................................................
    V                                                           
  <main resource needs sync>                                  n   t
    | yes               | no                                  a   y
    V                   V                                     t   p
  sync main resource    stop                                  i   e
    |                                                         v
    V                                                         e  
  stop

```

## Setup

### What only_before_sync affects
The module doesn't control physical resources on the machine, only the
manipulation of the final catalog

### Setup Requirements **OPTIONAL**

If your module requires anything extra before setting up (pluginsync enabled,
etc.), mention it here.

If your most recent release breaks compatibility or requires particular steps
for upgrading, you might want to include an additional "Upgrading" section
here.

### Beginning with only_before_sync

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
