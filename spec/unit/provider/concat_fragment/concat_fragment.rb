#! /usr/bin/env ruby

require 'spec_helper'
require 'puppet/provider/concat_fragment/concat_fragment'

describe Puppet::Type.type(:concat_fragment).provider(:concat_fragment) do
  let(:resource) do
    Puppet::Type.type(:concat_fragment).new(
      :ensure   => :present,
      :name     => 'test_concat_fragment',
      :target   => '/test/test_concat_file',
      :content  => 'hello rspec')
  end

  let(:provider) do
    described_class.new(resource)
  end

end
