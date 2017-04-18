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

require "kitchen/verifier/terraform/configure_inspec_runner_connectivity/port"
::RSpec.describe ::Kitchen::Verifier::Terraform::ConfigureInspecRunnerConnectivity::Port do
  let :default_port do instance_double ::Object end
  let :options do {} end
  before do described_class.call default_port: default_port, group: group, options: options end
  subject do options.fetch "port" end
  context "when the group associates :port with an object" do
    let :group do {port: port} end
    let :port do instance_double ::Object end
    it "associates :port with the group's :port in the options" do is_expected.to be port end
  end
  context "when the group omits :port" do
    let :group do {} end
    it "associates :port with the default_port in the options" do is_expected.to be default_port end
  end
end
