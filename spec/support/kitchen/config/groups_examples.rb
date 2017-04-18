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

require "kitchen/config/groups"
::RSpec.shared_examples ::Kitchen::Config::Groups do
  describe "#finalize_config!" do
    let :configuration do default_config end
    let :described_instance do described_class.new configuration end
    shared_context "named group" do
      let :name_string do ::String.new end
      before do
        group_hash.store :name, name_string
        name_string.replace "abc"
      end
    end
    shared_context "valid :groups" do
      before do instance end
      subject do described_instance[:groups] end
    end
    shared_examples "the configuration is invalid" do
      subject do proc do instance end end
      it "raises a user error" do is_expected.to raise_error ::Kitchen::UserError, error_message end
    end
    shared_examples "the configuration is valid" do
      include_context "valid :groups"
      it "permits the configuration" do is_expected.to match validated_groups end
    end
    context "when the configuration omits :groups" do
      include_context "valid :groups"
      it "alters the configuration to associate :groups with an empty array" do is_expected.to eq [] end
    end
    context "when the configuration associates :groups with a nonarray" do
      before do configuration.store :groups, 123 end
      it_behaves_like "the configuration is invalid" do let :error_message do /groups.*must be an array/ end end
    end
    context "when the configuration associates :groups with a groups array" do
      let :groups_array do [] end
      before do configuration.store :groups, groups_array end
      context "when the groups array is empty" do
        it_behaves_like "the configuration is valid" do let :validated_groups do [] end end
      end
      context "when the groups array contains a nonhash" do
        before do groups_array.push 123 end
        it_behaves_like "the configuration is invalid" do let :error_message do /groups.*0.*must be a hash/ end end
      end
      context "when the groups array contains a group hash" do
        let :group_hash do {} end
        before do groups_array.push group_hash end
        context "when the group hash omits :name" do
          it_behaves_like "the configuration is invalid" do let :error_message do /groups.*0.*name.*is missing/ end end
        end
        context "when the group hash associates :name with a nonstring" do
          before do group_hash.store :name, 123 end
          it_behaves_like "the configuration is invalid" do
            let :error_message do /groups.*0.*name.*must be a string/ end
          end
        end
        context "when the group hash associates :name with a name string" do
          include_context "named group"
          context "when the name string is empty" do
            before do name_string.replace "" end
            it_behaves_like "the configuration is invalid" do
              let :error_message do /groups.*0.*name.*must be filled/ end
            end
          end
          context "when the name string is nonempty" do
            it_behaves_like "the configuration is valid" do let :validated_groups do [including(name: "abc")] end end
          end
        end
        context "when the group hash omits :attributes" do
          include_context "named group"
          include_context "valid :groups"
          it "alters the configuration to associate :attributes with an empty hash" do
            is_expected.to match [including(attributes: {})]
          end
        end
        context "when the group hash associates :attributes with a nonhash" do
          before do group_hash.store :attributes, 123 end
          it_behaves_like "the configuration is invalid" do
            let :error_message do /groups.*0.*attributes.*must be a hash/ end
          end
        end
        context "when the group hash associates :attributes with an attributes hash" do
          include_context "named group"
          let :attributes_hash do {} end
          before do group_hash.store :attributes, attributes_hash end
          context "when the attributes hash is empty" do
            it_behaves_like "the configuration is valid" do let :validated_groups do [including(attributes: {})] end end
          end
          context "when the attributes hash associates nonstrings and nonsymbols" do
            before do attributes_hash.store 123, true end
            it_behaves_like "the configuration is invalid" do
              let :error_message do /groups.*0.*attributes.*keys and values must be strings or symbols/ end
            end
          end
          context "when the attributes hash associates strings and symobls" do
            before do
              attributes_hash.store "key", :value
              attributes_hash.store :key, "value"
            end
            it_behaves_like "the configuration is valid" do
              let :validated_groups do [including(attributes: {"key" => :value, key: "value"})] end
            end
          end
        end
        context "when the group hash omits :controls" do
          include_context "named group"
          include_context "valid :groups"
          it "alters the configuration to associate :controls with an empty array" do
            is_expected.to match [including(controls: [])]
          end
        end
        context "when the group hash associates :controls with a nonarray" do
          include_context "named group"
          before do group_hash.store :controls, 123 end
          it_behaves_like "the configuration is invalid" do
            let :error_message do /groups.*0.*controls.*must be an array/ end
          end
        end
        context "when the group hash associates :controls with a controls array" do
          include_context "named group"
          let :controls_array do [] end
          before do group_hash.store :controls, controls_array end
          context "when the controls array is empty" do
            it_behaves_like "the configuration is valid" do let :validated_groups do [including(controls: [])] end end
          end
          context "when the controls array includes a nonstring" do
            before do controls_array.push 123 end
            it_behaves_like "the configuration is invalid" do
              let :error_message do /groups.*0.*controls.*0.*must be a string/ end
            end
          end
          context "when the controls array includes a string" do
            before do controls_array.push "abc" end
            it_behaves_like "the configuration is valid" do
              let :validated_groups do [including(controls: ["abc"])] end
            end
          end
        end
        context "when the group hash associates :hostnames with a nonstring" do
          include_context "named group"
          before do group_hash.store :hostnames, 123 end
          it_behaves_like "the configuration is invalid" do
            let :error_message do /groups.*0.*hostnames.*must be a string/ end
          end
        end
        context "when the group hash associates :hostnames with a hostnames string" do
          include_context "named group"
          let :hostnames_string do ::String.new end
          before do group_hash.store :hostnames, hostnames_string end
          context "when the hostnames string is empty" do
            it_behaves_like "the configuration is valid" do let :validated_groups do [including(hostnames: "")] end end
          end
          context "when the hostnames string is nonempty" do
            before do hostnames_string.replace "abc" end
            it_behaves_like "the configuration is valid" do
              let :validated_groups do [including(hostnames: "abc")] end
            end
          end
        end
        context "when the group hash associates :port with a noninteger" do
          include_context "named group"
          before do group_hash.store :port, "abc" end
          it_behaves_like "the configuration is invalid" do
            let :error_message do /groups.*0.*port.*must be an integer/ end
          end
        end
        context "when the group hash associates :port with an integer" do
          include_context "named group"
          before do group_hash.store :port, 123 end
          it_behaves_like "the configuration is valid" do let :validated_groups do [including(port: 123)] end end
        end
        context "when the group hash associates :username with a nonstring" do
          include_context "named group"
          before do group_hash.store :username, 123 end
          it_behaves_like "the configuration is invalid" do
            let :error_message do /groups.*0.*username.*must be a string/ end
          end
        end
        context "when the group hash associates :username with a username string" do
          include_context "named group"
          let :username_string do ::String.new end
          before do group_hash.store :username, username_string end
          context "when the username string is empty" do
            it_behaves_like "the configuration is valid" do let :validated_groups do [including(username: "")] end end
          end
          context "when the username string is nonempty" do
            before do username_string.replace "abc" end
            it_behaves_like "the configuration is valid" do
              let :validated_groups do [including(username: "abc")] end
            end
          end
        end
      end
    end
  end
end
