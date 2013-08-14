
concat { "/tmp/foo": }
concat::fragment { "test_concat":
  target => "/tmp/foo",
  content => "hello puppet"
}
