# frozen_string_literal: true

# Copyright 2016-2017 New Context Services, Inc.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

require "kitchen"
require "kitchen/config/cli"
require "terraform/configurable"
require "terraform/version"
# Terraform state lifecycle activities manager
::Kitchen::Driver::Terraform = ::Class.new ::Kitchen::Driver::Base
::Kitchen::Config::CLI.call plugin_class: ::Kitchen::Driver::Terraform
::Kitchen::Driver::Terraform.include ::Terraform::Configurable
::Kitchen::Driver::Terraform.kitchen_driver_api_version 2
::Kitchen::Driver::Terraform.no_parallel_for
::Kitchen::Driver::Terraform.class_eval do
  define_method :create do |_state = nil| end
  define_method :destroy do |_state = nil|
    begin
      load_state do client.apply_destructively end
    rescue ::Kitchen::StandardError, ::SystemCallError => error
      raise ::Kitchen::ActionFailed, error.message
    end
  end
  define_method :verify_dependencies do
    version.if_not_supported do
      raise ::Kitchen::UserError, "#{version} is not supported\nInstall #{::Terraform::Version.latest}"
    end
    version
      .if_deprecated do log_deprecation aspect: version.to_s, remediation: "Install #{::Terraform::Version.latest}" end
  end
  define_method :load_state do |&block|
    begin
      silent_client.load_state(&block)
    rescue ::Errno::ENOENT => error
      debug error.message
    end
  end
  define_method :version do @version ||= ::Terraform::Client.new(config: self, logger: debug_logger).version end
  private :load_state, :version
end
