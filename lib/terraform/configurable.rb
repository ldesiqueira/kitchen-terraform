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

require "forwardable"
require "kitchen"
require "terraform/client"
require "terraform/debug_logger"
require "terraform/project_version"
module Terraform
  # Behaviour for objects that extend ::Kitchen::Configurable
  module Configurable
    extend ::Forwardable
    def_delegator :config, :[]=
    def_delegators :instance, :driver, :provisioner, :transport
    define_singleton_method :included do |configurable_class|
      configurable_class.plugin_version ::Terraform::PROJECT_VERSION
    end
    define_method :client do ::Terraform::Client.new config: verbose_config, logger: logger end
    define_method :config_deprecated do |attr:, remediation:, type:|
      log_deprecation aspect: "#{formatted_config attr: attr} as #{type}", remediation: remediation
    end
    define_method :config_error do |attr:, expected:|
      raise ::Kitchen::UserError, "#{formatted_config attr: attr} must be interpretable as #{expected}"
    end
    define_method :debug_logger do ::Terraform::DebugLogger.new logger: logger end
    define_method :instance_pathname do |filename:|
      ::File.join config.fetch(:kitchen_root), ".kitchen", "kitchen-terraform", instance.name, filename
    end
    define_method :log_deprecation do |aspect:, remediation:|
      logger.warn "DEPRECATION NOTICE"
      logger.warn "Support for #{aspect} will be dropped in kitchen-terraform v1.0"
      logger.warn remediation
    end
    define_method :silent_client do ::Terraform::Client.new config: silent_config, logger: debug_logger end
    define_method :formatted_config do |attr:| "#{self.class}#{instance.to_str}#config[:#{attr}]" end
    define_method :silent_config do verbose_config.tap do |config| config[:color] = false end end
    define_method :verbose_config do provisioner.dup.tap do |config| config[:cli] = driver[:cli] end end
    private :formatted_config, :silent_config, :verbose_config
  end
end
