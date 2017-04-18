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

require "dry-validation"
require "kitchen/config/groups"
::Kitchen::Config::Groups::Schema = ::Dry::Validation.Schema do
  configure do
    define_method :strings_or_symbols? do |hash|
      hash.all? do |key, value|
        (key.is_a?(::String) | key.is_a?(::Symbol)) & (value.is_a?(::String) | value.is_a?(::Symbol))
      end
    end
    define_singleton_method :messages do
      super().merge en: {errors: {strings_or_symbols?: "keys and values must be strings or symbols"}}
    end
  end
  required(:value).each do
    schema do
      required(:name).filled :str?
      optional(:attributes).value :hash?, :strings_or_symbols?
      optional(:controls).each :filled?, :str?
      optional(:hostnames).value :str?
      optional(:port).value :int?
      optional(:username).value :str?
    end
  end
end
