#!/usr/bin/env puppet apply

$target_dir = "/tmp/test_concat_examples"
$target_large = "${target_dir}/test_concat_large.dat"

file { $target_dir:
  ensure => directory,
  owner  => root,
  group  => root,
  mode   => '0700',
}

define test_concat_large($target) {

	if (defined(Concat[$target]) == false) {
		concat { $target:
      owner  => 'puppet',
      group  => 'puppet',
      mode   => '0444',
		}
	}

	concat_fragment { "filetest_${name}":
    target  => $target,
		content => $name,
	}

}

$list = [
'111111',
'11111111',
'112233',
'121212',
'123123',
'123456',
'1234567',
'12345678',
'131313',
'232323',
'654321',
'666666',
'696969',
'777777',
'7777777',
'8675309',
'987654',
'aaaaaa',
'abc123',
'abcdef',
'abgrtyu',
'access',
'access14',
'action',
'albert',
'alexis',
'amanda',
'amateur',
'andrea',
'andrew',
'angela',
'angels',
'animal',
'anthony',
'apollo',
'apples',
'arsenal',
'arthur',
'asdfgh',
'ashley',
'august',
'austin',
'badboy',
'bailey',
'banana',
'barney',
'baseball',
'batman',
'this',
'that',
'thar',
'bob',
'maia',
'is',
'the',
'best',
]

# a puppet iterator foreach element in $list
test_concat_large { $list:
    target  => $target_large,
    require => File[$target_dir],
}
