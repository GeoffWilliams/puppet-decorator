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
`only_before_sync` allows you to designate specific resources to run ONLY when a resources is scheduled to be synced (run).

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
manipulation of the final catalog which is done from the _agent_ node with
validation taking place on the _master_.

This is done in a very similar way to the [puppetlabs/transition](https://forge.puppet.com/puppetlabs/transition) module
which is a good 'see also'

## Usage
Usage is best illustrated by a worked example:

```puppet
# The package to install that we will attach our exec resources to
# notice that it is before all other resources even though it needs
# to be processed internally _last_.  The type and provider will
# reorder the graph at compile time to take care of this
package { "nmap-ncat":
  ensure => present,
}

# Query RPM to verify that the package is not installed yet and write this to a
# file, proving that the package resource has not yet been processed.  In
# real-world useage, a script that you only wanted to run on install or upgrade
# would be set as the command here.
exec { "before_package_installed":
  noop    => true,
  command => '/bin/rpm -q nmap-ncat > /tmp/exec.txt',
  returns => 1, # Expect exit status 1 from rpm if package not installed
}

# Make our 2 exec resources run before package installation only
# if an upgrade/install is happening.  You can add multiple resources
# by using an array or just refer to a single resource.  All resources *MUST* be
# marked as noop in your puppet code.  The provider works by turning off noop
# mode if the main resource requires a sync
only_before_sync { "testing123":
  resource    => Package['nmap-ncat'],
  before_sync => [
    Exec["before_package_installed"],
    Exec["demo"]
  ],
}

# an additional exec resource just to prove that we can handle more then one
exec { "demo":
  noop    => true,
  command => "/bin/date > /tmp/demo.txt",
}
```

### Key steps/features
* Define the resources that you wish to conditionally run and set their `noop`
  parameter (the `exec` resources)
* Add the main resource (the `package`)
* Add an `only_before_sync` resource to _glue_ everything together
  * `only_before_sync` will re-order dependencies by adding the equivalent
    `before` and `require` edges to the dependency graph
  * The `name`/`title` of the resource are for reference/de-duplication purposes
    only and can be set to anything unique
  * The `before_sync` attribute uses the [Puppet referencing syntax](https://docs.puppet.com/puppet/latest/reference/lang_data_resource_reference.html#the-short-version) to reference one or more resources in `noop` mode
  * If the resource identified by the `resource` parameter needs to sync, `noop`
    mode will be removed from all resources referenced by `before_sync`
  * The `resource` attribute is a reference to the resource which will used to
    test whether the resources referenced in the `before_sync` parameter should
    be enabled during this Puppet run
  * In this example, we have used the `exec` and `package` resources because
    this illustrates a the main customer usage of this module.  You may,
    however, use any resource types you like as long as they are native type and
    providers and implement the `insync` method in the Puppet type definition

## Reference
### `only_before_sync`
Custom type and provider to allow running resources before another resource is synced

## Limitations
* Not supported by Puppet

## Development
Pull Requests welcome

## Testing
Users of this module are strongly encouraged to carry out their own testing to
verify correct operation.  This project is also complete with acceptance tests
written using:
* [Test Kitchen](http://kitchen.ci)
* [Kitchen-Puppet](https://github.com/neillturner/kitchen-puppet)
* [Bats](https://github.com/sstephenson/bats)

Tests currently use Docker so you will need this setup on the machine you are
testing from.

DO NOT RUN TESTS FROM A PUPPET MASTER!

To run them tests, first prepare your system:
```shell
bundle install
```

And then run all test suites by running:
```shell
bundle exec kitchen verify
```
This will run end-to-end testing by creating a container, installing the Puppet
code and running the tests.

If desired, you can instead run the stages of the test suite individually:
* `bundle exec kitchen create` - Create the test container/vm infrastructure
* `bundle exec kitchen converge` - Run Puppet inside the container
* `bundle exec kitchen verify` - Check the state of the system after running
  Puppet

It is suggested to have your CI server execute these tests before allowing code
to be published to the puppet master
