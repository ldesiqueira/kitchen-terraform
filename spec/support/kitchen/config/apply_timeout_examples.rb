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
require "kitchen/config/apply_timeout"

::RSpec.shared_examples ::Kitchen::Config::ApplyTimeout do
  describe "#finalize_config!" do
    let :configuration do default_config end

    let :described_instance do described_class.new configuration end

    shared_examples "the configuration is invalid" do
      subject do proc do instance end end

      it "raises a user error" do
        is_expected.to raise_error ::Kitchen::UserError, error_message
      end
    end

    shared_context "valid :apply_timeout" do
      before do instance end

      subject do described_instance[:apply_timeout] end
    end

    shared_examples "the configuration is valid" do
      include_context "valid :apply_timeout"

      it "permits the configuration" do
        is_expected.to match validated_apply_timeout
      end
    end

    context "when the configuration omits :apply_timeout" do
      include_context "valid :apply_timeout"

      it "alters the configuration to associate :apply_timeout with 600" do
        is_expected.to eq 600
      end
    end

    context "when the configuration associates :apply_timeout with a " \
              "noninteger" do
      before do configuration.store :apply_timeout, "abc" end

      it_behaves_like "the configuration is invalid" do
        let :error_message do /apply_timeout.*must be an integer/ end
      end
    end

    context "when the configuration associates :apply_timeout with an " \
              "integer" do
      before do configuration.store :apply_timeout, 123 end

      it_behaves_like "the configuration is valid" do
        let :validated_apply_timeout do 123 end
      end
    end
  end
end
