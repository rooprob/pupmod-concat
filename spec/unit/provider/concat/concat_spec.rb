#! /usr/bin/env ruby

require 'spec_helper'
require 'puppet/provider/concat/concat'

describe Puppet::Type.type(:concat).provider(:concat) do
  let(:resource) do
    Puppet::Type.type(:concat).new(
      :ensure   => :present,
      :name     => '/test/test_concat_file',
      :owner    => 'puppet',
      :group    => 'puppet',
      :mode     => '0644')
  end

  let(:provider) do
    described_class.new(resource)
  end

end
