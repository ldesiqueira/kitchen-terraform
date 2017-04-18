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

require "kitchen/verifier/terraform"
::Kitchen::Verifier::Terraform::ConfigureInspecRunnerConnectivity = ::Module.new
require "kitchen/verifier/terraform/configure_inspec_runner_connectivity/backend"
require "kitchen/verifier/terraform/configure_inspec_runner_connectivity/host"
require "kitchen/verifier/terraform/configure_inspec_runner_connectivity/port"
require "kitchen/verifier/terraform/configure_inspec_runner_connectivity/user"
::Kitchen::Verifier::Terraform::ConfigureInspecRunnerConnectivity.class_eval do
  define_singleton_method :call do |default_port:, default_user:, group:, host:, options:|
    ::Kitchen::Verifier::Terraform::ConfigureInspecRunnerConnectivity::Backend.call host: host, options: options
    ::Kitchen::Verifier::Terraform::ConfigureInspecRunnerConnectivity::Host.call host: host, options: options
    ::Kitchen::Verifier::Terraform::ConfigureInspecRunnerConnectivity::Port
      .call default_port: default_port, group: group, options: options
    ::Kitchen::Verifier::Terraform::ConfigureInspecRunnerConnectivity::User
      .call default_user: default_user, group: group, options: options
  end
end
