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
require "kitchen/config/color"

::RSpec.shared_examples ::Kitchen::Config::Color do
  describe "#finalize_config!" do
    let :configuration do default_config end

    let :described_instance do described_class.new configuration end

    shared_examples "the configuration is invalid" do
      subject do proc do instance end end

      it "raises a user error" do
        is_expected.to raise_error ::Kitchen::UserError, error_message
      end
    end

    shared_context "valid :color" do
      before do instance end

      subject do described_instance[:color] end
    end

    shared_examples "the configuration is valid" do
      include_context "valid :color"

      it "permits the configuration" do
        is_expected.to match validated_color
      end
    end

    context "when the configuration omits :color" do
      include_context "valid :color"

      it "alters the configuration to associate :color with true" do
        is_expected.to be true
      end
    end

    context "when the configuration associates :color with a nonboolean" do
      before do configuration.store :color, "abc" end

      it_behaves_like "the configuration is invalid" do
        let :error_message do /color.*must be boolean/ end
      end
    end

    context "when the configuration associates :color with a boolean" do
      before do configuration.store :color, false end

      it_behaves_like "the configuration is valid" do
        let :validated_color do false end
      end
    end
  end
end
