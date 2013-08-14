Puppet Concat Module
====================

This is a module that provides a native type for performing multi-part file
concatenation, generally referred to by the [Puppet Labs](http://www.puppetlabs.com) team as the File Fragment Pattern.

The concept is based on ideas that R.I. Pienaar describes on his [Building
files from fragments in Puppet](http://www.devco.net/archives/2010/02/19/building_files_from_fragments_with_puppet.php) page.

This module is a fork of https://github.com/onyxpoint/pupmod-concat, changed to
more closely follow the ripienaar module and be (mostly) API compatible.

This module currently drops some of the features in onyxpoint/pupmod-concat,
please file requests for improvements in the github you found this file.

This instruction README has been modified to match our ripienaar-like version.

Installation
------------

The recommended way to install this package is either through the Puppet module
manager or via RPM. A spec file has been included that can be used to create an
RPM if required.

This module is known to be compatible with Puppet 2.7.

Basic Usage
-----------

This module has been designed to be quite flexible but follows the basic
pattern of specifying file fragments and subsequently building a target file.

See the comments in the code for the definition of all options.

    concat { "/tmp/tests":
      owner => 'puppet',
      group => 'staff',
      mode  => '0640',
    }

    concat_fragment { "a_unique_name.1":
      content => "Some random stuff",
      target  => "/tmp/test"
    }

    concat_fragment { "a_unique_name.2":
      content => "Some other random stuff",
      target  => "/tmp/test"
    }

Delimited Fragements
--------------------

If, for example, you wanted your fragments to join together to be a
comma-separated list, you can achieve this by doing:

    concat { "/tmp/test":
      order => ['*.tmp'],
      file_delimiter => ",",
    }

Notes
-----

Concat fragments are stored under Puppet[:vardir]/concat/fragments. The
permissions of which are set in type/concat_fragment specifically to prevent
non-puppet members from accessing.

Testing
-------

Examples in lieu of a proper testing suite in tests/. Alter the following as
required to point to the parent of a directory hosting the library,

puppet apply  --no-daemonize --modulepath /enterproid/projects/puppet-mods/concat-robfield/ /enterproid/projects/puppet-mods/concat-robfield/concat/tests/test_concat_robfield.pp

puppet apply  --no-daemonize --modulepath /enterproid/projects/puppet-mods/concat-ripienaar/ /enterproid/projects/puppet-mods/concat-robfield/concat/tests/test_concat_ripienaar.pp

A diff -r should yield no difference, expect in the ordering of the large file
test ; as the order is unspecified this I will accept - the ordered tests
return expected results.

Anecdotally, on a 2013 Macbook Air running Vagrant/Virtbox/Ubuntu/Puppet 2.7
the difference is 1.5s vs 20s.

Copyright
---------
Copyright (C) 2013 Robert Fielding <robert.fielding@enterproid.com>

This source has been modified at the API level, see NOTICE.

Copyright (C) 2012 Onyx Point, Inc. <http://onyxpoint.com/>

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

   http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
