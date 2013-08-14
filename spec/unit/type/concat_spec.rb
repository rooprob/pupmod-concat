#/usr/bin/env ruby

require 'spec_helper'

concat = Puppet::Type.type(:concat)

describe concat do

  before do
    @class = concat
    @provider_class = @class.provide(:fake) { mk_resource_methods }
    @provider = @provider_class.new
    @resource = stub 'resource', :resource => nil, :provider => @provider

    @class.stubs(:defaultprovider).returns @provider_class
    @class.any_instance.stubs(:provider).returns @provider
  end

  describe "when validating attributes" do

    [:safename, :owner, :group, :mode].each do |param|
      it "should have a #{param} parameter" do
        @class.attrtype(param).should == :param
      end
    end

    [:name, :ensure].each do |param|
      it "should have a #{param} property" do
        @class.attrtype(param).should == :property
      end
    end
  end


  describe "when validating values" do

      describe "for ensure" do
          it "should basic created" do
              proc { @class.new(:name => "/mnt/foo") }.should_not raise_error
          end
      end

      describe "for name" do

          it "should support normal paths for name" do
              proc { @class.new(:name => "/mnt/foo", :ensure => :present) }.should_not raise_error
              proc { @class.new(:name => "/media/cdrom_foo_bar", :ensure => :present) }.should_not raise_error
          end

          it "should be fully qualified in name" do
              proc { @class.new(:name => "mnt/foobar", :ensure => :present) }.should raise_error(Puppet::Error, /name must be an absolute path/)
              proc { @class.new(:name => "foo", :ensure => :present) }.should raise_error(Puppet::Error, /name must be an absolute path/)
          end

          it "should not support spaces in name" do
              proc { @class.new(:name => "/mnt/foo bar", :ensure => :present) }.should raise_error(Puppet::Error, /name is not allowed to contain whitespace/)
              proc { @class.new(:name => "/m nt/foo", :ensure => :present) }.should raise_error(Puppet::Error, /name is not allowed to contain whitespace/)
          end

          it "should not support trailing slashes" do
              proc { @class.new(:name => "/mnt/foo/", :ensure => :present) }.should raise_error(Puppet::Error, /name is not allowed to have trailing slashes/)
              proc { @class.new(:name => "/mnt/foo//", :ensure => :present) }.should raise_error(Puppet::Error, /name is not allowed to have trailing slashes/)
          end
      end
  end
end
