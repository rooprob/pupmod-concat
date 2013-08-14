#
# Copyright (C) 2013 Robert Fielding <robert.fielding@enterproid.com>
#
# This source has been modified at the API level, see NOTICE.
#
#
# Copyright (C) 2012 Onyx Point, Inc. <http://onyxpoint.com/>
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#    http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#
Puppet::Type.newtype(:concat_fragment) do
  @doc = "Create a concat fragment. If you do not create an associated
          concat object, then one will be created for you and the
          defaults will be used."

  ensurable

  newparam(:name) do
    isnamevar
  end

  newparam(:order) do
    desc "Order of the concat"
    defaultto '10'

  end

  newparam(:target) do
    desc "Fully qualified path to copy output file to"

    validate do |value|
      raise Puppet::Error, "target is not allowed to contain whitespace" if value =~ /\s/
      raise Puppet::Error, "target is not allowed to have trailing slashes" if value =~ %r{/$}
      raise Puppet::Error, "target must be an absolute path" if value =~ %r{^[^/]} or value =~ %r{/../}
    end
  end

  newparam(:safetarget) do
    desc "Ignore me, I'm a convienience stub"

    munge do |value|
      @resource[:target].gsub /\//, '_'
    end

    validate do |value|
      fail Puppet::Error, "you must specify target" unless value
    end

  end

  newparam(:safename) do
    desc "Ignore me, I'm a convienience stub"
    defaultto 'fake'

    munge do |value|
      @resource[:name].gsub /\//, '_'
    end
  end

  newparam(:frag_name) do
    desc "Ignore me, I'm a convienience stub"
    defaultto 'fake'

    munge do |value|
      value = "#{resource[:order]}_#{resource[:safename]}"
    end
  end

  newproperty(:content) do

      def retrieve

          !@frags_to_delete and @frags_to_delete = []
          return provider.retrieve
      end

      def insync?(is)
          is and @should or return false

          # @should is an Array through Puppet magic.
          is.strip == @should.first.strip
      end

      def sync
          provider.create
      end

  end

  # This is only here because, at this point, we can be sure that the catalog
  # has been compiled. This checks to see if we have a concat specified
  # for our particular concat_fragment group.
  autorequire(:file) do
    if not catalog.resource("Concat[#{self[:target]}]") then
      err "No 'concat' specified for group '#{self[:target]}'"
    end
    ""
  end

  validate do
    fail Puppet::Error, "You must specify content" unless self[:content]
    fail Puppet::Error, "You must specify target" unless self[:target]
  end

  def create_default_build
    # If the user did not specify a concat object in their manifest,
    # assume that they want the defaults and create one for them.
    if not @catalog.resource("Concat[#{self[:target]}]") then
      debug "Auto-adding 'concat' resource Concat['#{self[:target]}'] to the catalog"
      @catalog.add_resource(Puppet::Type.type(:concat).new(
        :name => "#{self[:target]}"
      ))
    end
    if not @catalog.resource("File[#{Puppet[:vardir]}/concat]") then
      debug "Auto-adding 'concat' resource File[#{Puppet[:vardir]}/concat] to the catalog"
      @catalog.add_resource(Puppet::Type.type(:file).new(
        :name => "#{Puppet[:vardir]}/concat",
        :ensure => 'directory',
        :owner => 'puppet',
        :group => 'puppet',
        :mode => '0750'))
    end
  end

  def purge_unknown_fragments
    # Kill all unmanaged fragments for this group
    known_resources = []

    # Find everything that we shouldn't delete.
    catalog.resources.find_all { |r|
      (r.is_a?(Puppet::Type.type(:concat_fragment)) and r[:target] == self[:target] ) or
      (r.is_a?(Puppet::Type.type(:concat)) and r[:name] == self[:target])
    }.each do |frag_res|
      if frag_res.is_a?(Puppet::Type.type(:concat_fragment)) then
        known_resources << "#{Puppet[:vardir]}/concat/fragments/#{frag_res[:safetarget]}/#{frag_res[:frag_name]}"
      elsif frag_res.is_a?(Puppet::Type.type(:concat)) then
        known_resources << frag_res[:name]
      else
        debug "Woops, found an unknown fragment of type #{frag_res.class}"
      end
    end

    (Dir.glob("#{Puppet[:vardir]}/concat/fragments/#{self[:safetarget]}/*") - known_resources).each do |to_del|
      debug "Deleting Unused Fragment: #{to_del}"
      FileUtils.rm(to_del)
    end
  end

  def finish
    create_default_build
    purge_unknown_fragments
    super
  end
end
