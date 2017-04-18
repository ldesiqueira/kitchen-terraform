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
require "kitchen/config/parallelism"

::RSpec.shared_examples ::Kitchen::Config::Parallelism do
  describe "finalize_config!" do
    let :configuration do default_config end

    let :described_instance do described_class.new configuration end

    shared_examples "the configuration is invalid" do
      subject do proc do instance end end

      it "raises a user error" do
        is_expected.to raise_error ::Kitchen::UserError, error_message
      end
    end

    shared_context "valid :parallelism" do
      before do instance end

      subject do described_instance[:parallelism] end
    end

    shared_examples "the configuration is valid" do
      include_context "valid :parallelism"

      it "permits the configuration" do
        is_expected.to match validated_parallelism
      end
    end

    context "when the configuration omits :parallelism" do
      include_context "valid :parallelism"

      it "alters the configuration to associate :parallelism with 10" do
        is_expected.to eq 10
      end
    end

    context "when the configuration associates :parallelism with a " \
              "noninteger" do
      before do configuration.store :parallelism, "abc" end

      it_behaves_like "the configuration is invalid" do
        let :error_message do /parallelism.*must be an integer/ end
      end
    end

    context "when the configuration associates :parallelism with an integer" do
      before do configuration.store :parallelism, 123 end

      it_behaves_like "the configuration is valid" do
        let :validated_parallelism do 123 end
      end
    end
  end
end
