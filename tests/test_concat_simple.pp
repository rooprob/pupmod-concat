
concat { "/tmp/foo": }
concat_fragment { "test_concat":
  target => "/tmp/foo",
  content => "hello puppet"
}
