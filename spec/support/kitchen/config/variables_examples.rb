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
require "kitchen/config/variables"

::RSpec.shared_examples ::Kitchen::Config::Variables do
  describe "finalize_config!" do
    let :configuration do default_config end

    let :described_instance do described_class.new configuration end

    shared_examples "the configuration is invalid" do
      subject do proc do instance end end

      it "raises a user error" do
        is_expected.to raise_error ::Kitchen::UserError, error_message
      end
    end

    shared_context "valid :variables" do
      before do instance end

      subject do described_instance[:variables] end
    end

    shared_examples "the configuration is valid" do
      include_context "valid :variables"

      it "permits the configuration" do
        is_expected.to match validated_variables
      end
    end

    context "when the configuration omits :variables" do
      include_context "valid :variables"

      it "alters the configuration to associate :variables with an empty " \
           "hash" do
        is_expected.to eq ::Hash.new
      end
    end

    context "when the configuration associates :variables with a nonhash" do
      before do configuration.store :variables, "abc" end

      it_behaves_like "the configuration is invalid" do
        let :error_message do /variables.*must be a hash/ end
      end
    end

    context "when the configuration associates :variables with a hash" do
      before do configuration.store :variables, {} end

      it_behaves_like "the configuration is valid" do
        let :validated_variables do {} end
      end
    end
  end
end
