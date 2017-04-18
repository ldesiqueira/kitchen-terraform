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

require "kitchen/verifier/inspec"
# Runs tests post-converge to confirm that instances in the Terraform state are in an expected state
::Kitchen::Verifier::Terraform = ::Class.new ::Kitchen::Verifier::Inspec
require "kitchen/config/groups"
require "kitchen/verifier/terraform/configure_inspec_runner_connectivity"
require "kitchen/verifier/terraform/configure_inspec_runner_profile"
require "kitchen/verifier/terraform/enumerate_group_hosts"
require "terraform/configurable"
::Kitchen::Config::Groups.call plugin_class: ::Kitchen::Verifier::Terraform
::Kitchen::Verifier::Terraform.include ::Terraform::Configurable
::Kitchen::Verifier::Terraform.kitchen_verifier_api_version 2
::Kitchen::Verifier::Terraform.class_eval do
  define_method :call do |state|
    begin
      config.fetch(:groups).each do |group|
        state.store :group, group
        ::Kitchen::Verifier::Terraform::EnumerateGroupHosts.call client: silent_client, group: group do |host:|
          state.store :host, host
          info "Verifying '#{host}' of group '#{group.fetch :name}'"
          super state
        end
      end
    rescue ::Kitchen::StandardError, ::SystemCallError => error
      raise ::Kitchen::ActionFailed, error.message
    end
  end
  define_method :runner_options do |transport, state = {}, platform = nil, suite = nil|
    super(transport, state, platform, suite).tap do |options|
      ::Kitchen::Verifier::Terraform::ConfigureInspecRunnerConnectivity
        .call default_port: transport[:port], default_user: transport[:user], group: state.fetch(:group),
              host: state.fetch(:host), options: options
      ::Kitchen::Verifier::Terraform::ConfigureInspecRunnerProfile
        .call client: silent_client, config: config, group: state.fetch(:group), options: options,
              terraform_state: provisioner[:state]
    end
  end
  private :runner_options
end
