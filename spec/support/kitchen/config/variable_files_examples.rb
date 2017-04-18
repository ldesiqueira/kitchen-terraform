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
require "kitchen/config/variable_files"

::RSpec.shared_examples ::Kitchen::Config::VariableFiles do
  describe "finalize_config!" do
    let :configuration do default_config end

    let :described_instance do described_class.new configuration end

    shared_examples "the configuration is invalid" do
      subject do proc do instance end end

      it "raises a user error" do
        is_expected.to raise_error ::Kitchen::UserError, error_message
      end
    end

    shared_context "valid :variable_files" do
      before do instance end

      subject do described_instance[:variable_files] end
    end

    shared_examples "the configuration is valid" do
      include_context "valid :variable_files"

      it "permits the configuration" do
        is_expected.to match validated_variable_files
      end
    end

    context "when the configuration omits :variable_files" do
      include_context "valid :variable_files"

      it "alters the configuration to associate :variable_files with an " \
           "empty array" do
        is_expected.to eq []
      end
    end

    context "when the configuration associates :variable_files with a " \
              "nonarray" do
      before do configuration.store :variable_files, "abc" end

      it_behaves_like "the configuration is invalid" do
        let :error_message do /variable_files.*must be an array/ end
      end
    end

    context "when the configuration associates :variable_files with an array" do
      let :array do [] end

      before do configuration.store :variable_files, array end

      context "when the array contains a nonstring" do
        before do array.push 123 end

        it_behaves_like "the configuration is invalid" do
          let :error_message do /variable_files.*0.*must be a string/ end
        end
      end

      context "when the array contains a string" do
        let :string do ::String.new end

        before do array.push string end

        context "when the string is empty" do
          it_behaves_like "the configuration is invalid" do
            let :error_message do /variable_files.*0.*must be filled/ end
          end
        end

        context "when the string is nonempty" do
          before do string.replace "abc" end

          it_behaves_like "the configuration is valid" do
            let :validated_variable_files do ["abc"] end
          end
        end
      end
    end
  end
end
