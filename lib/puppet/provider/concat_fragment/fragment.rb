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
Puppet::Type.type(:concat_fragment).provide :concat_fragment do
  require 'fileutils'

  desc "concat_fragment provider"

  def retrieve
      cur_file = "#{Puppet[:vardir]}/concat/fragments/#{@resource[:safetarget]}/#{@resource[:frag_name]}"

      cur_val = nil
      begin
        cur_val = File.read(cur_file)
      rescue Exception => e
        debug "Could not find file fragment #{cur_file}"
      end

      return cur_val
  end

  def create
    begin
      safetarget = @resource[:safetarget]
      fragment = @resource[:frag_name]

      FileUtils.mkdir_p("#{Puppet[:vardir]}/concat/fragments/#{safetarget}")
      f = File.new("#{Puppet[:vardir]}/concat/fragments/#{safetarget}/#{fragment}", "w")
      f.print @resource[:content]
      f.close
    rescue Exception => e
      fail Puppet::Error, e
    end
  end

  def destroy
    begin
      safetarget = @resource[:safetarget]
      fragment = @resource[:frag_name]

      File.unlink("#{Puppet[:vardir]}/concat/fragments/#{safetarget}/#{fragment}")
    rescue Exception => e
      fail Puppet::Error, e
    end
  end

  def exists?
    begin
      safetarget = @resource[:safetarget]
      fragment = @resource[:frag_name]

      File.exist?("#{Puppet[:vardir]}/concat/fragments/#{safetarget}/#{fragment}")
    rescue Exception => e
      fail Puppet::Error, e
    end
  end


end
