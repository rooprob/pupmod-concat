#/usr/bin/env ruby

require 'spec_helper'

concat_fragment = Puppet::Type.type(:concat_fragment)

describe concat_fragment do

    before do
        @class = concat_fragment
        @provider_class = @class.provide(:fake) { mk_resource_methods }
        @provider = @provider_class.new
        @resource = stub 'resource', :resource => nil, :provider => @provider

        @class.stubs(:defaultprovider).returns @provider_class
        @class.any_instance.stubs(:provider).returns @provider
    end

    describe "when validating attributes" do

        [:name, :target, :safetarget, :frag_name, :order].each do |param|
            it "should have a #{param} parameter" do
                @class.attrtype(param).should == :param
            end
        end

        [:ensure, :content].each do |param|
            it "should have a #{param} property" do
                @class.attrtype(param).should == :property
            end
        end
    end

    describe "when validating values" do

        describe "for ensure" do
            it "should basic created" do
                proc { @class.new(:name => 'test_concat_frag',
                                  :content => 'hello',
                                  :target => '/mnt/foo') }.should_not raise_error
            end
            it "should fail created" do
                proc { @class.new(:name => 'test_concat_frag',
                                  :target => '/mnt/foo') }.should raise_error
                proc { @class.new(:name => 'test_concat_frag',
                                  :content => 'hello') }.should raise_error
            end
        end

        describe "for name" do

            it "should support normal paths for target" do
                proc { @class.new(:name => 'test_concat_fragment',
                                  :target => "/mnt/foo",
                                  :content => 'hello',
                                  :ensure => :present) }.should_not raise_error
                proc { @class.new(:name => 'test_concat_fragment',
                                  :target => "/media/cdrom_foo_bar",
                                  :content => 'hello',
                                  :ensure => :present) }.should_not raise_error
            end

            it "should be fully qualified in target" do
                proc { @class.new(:name => "test_concat_fragment",
                                  :target => "mnt/foo",
                                  :content => 'hello',
                                  :ensure => :present) }.should raise_error(Puppet::Error, /target must be an absolute path/)
                proc { @class.new(:name => "test_concat_fragment",
                                  :target => "foo",
                                  :content => 'hello',
                                  :ensure => :present) }.should raise_error(Puppet::Error, /target must be an absolute path/)
            end

            it "should not support spaces in target" do
                proc { @class.new(:name => "test_concat_fragment",
                                  :target => "/mnt/foo ",
                                  :content => 'hello',
                                  :ensure => :present) }.should raise_error(Puppet::Error, /target is not allowed to contain whitespace/)
                proc { @class.new(:name => "test_concat_fragment",
                                  :target => "m nt/foo",
                                  :content => 'hello',
                                  :ensure => :present) }.should raise_error(Puppet::Error, /target is not allowed to contain whitespace/)
            end

            it "should not support trailing slashes" do
                proc { @class.new(:name => "test_concat_fragment",
                                  :target => "/mnt/foo/",
                                  :content => 'hello',
                                  :ensure => :present) }.should raise_error(Puppet::Error, /target is not allowed to have trailing slashes/)
                proc { @class.new(:name => "test_concat_fragment",
                                  :target => "/mnt/foo//",
                                  :content => 'hello',
                                  :ensure => :present) }.should raise_error(Puppet::Error, /target is not allowed to have trailing slashes/)
            end
        end
    end
end
