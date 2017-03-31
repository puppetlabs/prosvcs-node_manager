# node\_manager [![Build Status](https://travis-ci.org/puppetlabs/prosvcs-node_manager.svg)](https://travis-ci.org/puppetlabs/prosvcs-node_manager)

#### Table of Contents

1. [Overview](#overview)
1. [Requirements](#requirements)
1. [Types](#types)
    * [Node\_group](#node_group)
    * [Puppet\_environment](#puppet_environment)
1. [Functions](#functions)
    * [node\_groups()](#node_groups)

## Overview

Create and manage Node Manager API endpoints as resources.

## Module State

NOTE: This module is a Professional Service side project and is currently unmaintained.
It is not supported and may not function as expected.

## Requirements

* *nix operating system
* Puppet >= 3.7.1
* [puppetclassify](https://github.com/puppetlabs/puppet-classify) gem
* [puppetlabs/pe_gem module](https://forge.puppetlabs.com/puppetlabs/pe_gem)

## Classes

### Node\_manager

The node_manager class facilitates the deployment of the puppetclassify gem
simply include node_manager in your node definition or add it to the pe_master node group

## Types

### Node\_group

Node_groups will autorequire parent node_groups.

Enumerate all node groups:

* `puppet resource node_group`

Example output for `puppet resource node_group 'PE MCollective'`

```puppet
node_group { 'PE MCollective':
  ensure               => 'present',
  classes              => {'puppet_enterprise::profile::mcollective::agent' => {}},
  environment          => 'production',
  id                   => '4cdec347-20c6-46d7-9658-7189c1537ae9',
  override_environment => 'false',
  parent               => 'PE Infrastructure',
  rule                 => ['and', ['~', ['fact', 'pe_version'], '.+']],
}
```

#### Node\_group parameters

* `classes`

  Classes that are assigned to the node in hash format. Elements of the hash are class parameters.

  Default (empty hash): `{}`

* `environment`

  Environment selected for this node group.

  Default: `production`

* `name`

  (namevar) Node group's name.

* `id`

  Universal ID for the group. This attribute is read-only.

* `override_environment`

  Whether or not this group's environment ment setting overrides all other other environments.

  Default: `false`

* `parent`

  The UID for the data group. Can be specified by group name or UID.

  Default: `default`

* `rules`

  An array of classification rules.

  Default (empty array): `[]`

### Puppet\_environment

Enumerate all puppet environments:

* `puppet resource puppet_environment`

Example output for `puppet resource puppet_environment production`

```puppet
puppet_environment { 'production':
  ensure => 'present',
}
```

#### Puppet\_environment parameters

* `name`

  (namevar) Name of the Puppet environment on disk, i.e. the directory name in `$environmentpath`.

## Functions

### node\_groups()

Retrieve all or one node_group and its data.

`node_groups()` will return:

```puppet
{
  "default"=>{
    "environment_trumps"=>false,
    "parent"=>"00000000-0000-4000-8000-000000000000",
    "name"=>"default",
    "rule"=>["and", ["~", "name", ".*"]],
    "variables"=>{}, "id"=>"00000000-0000-4000-8000-000000000000",
    "environment"=>"production",
    "classes"=>{}
  },
  "Production environment"=>{
    "environment_trumps"=>false,
    "parent"=>"00000000-0000-4000-8000-000000000000",
    "name"=>"Production environment",
    "rule"=>["and", ["~", "name", ".*"]],
    "variables"=>{},
    "id"=>"7233f964-951e-4a7f-88ea-72676ed3104d",
    "environment"=>"production",
    "classes"=>{}
  },
  ...
}
```

`node_groups('default')` will return:

```puppet
{
  "default"=>{
    "environment_trumps"=>false,
    "parent"=>"00000000-0000-4000-8000-000000000000",
    "name"=>"default",
    "rule"=>["and", ["~", "name", ".*"]],
    "variables"=>{}, "id"=>"00000000-0000-4000-8000-000000000000",
    "environment"=>"production",
    "classes"=>{}
  }
}
  ```

_Type:_ rvalue

## Maintainers

This repositority is largely the work of the Puppet Labs Professional Services
team. It is not officially maintained by Puppet Labs, or any individual in
particular. Issues should be opened in github. Questions should be directed
at the individuals responsible for committing that particular code.

