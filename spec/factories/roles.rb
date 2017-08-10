# frozen_string_literal: true

FactoryGirl.define do
  factory :role do
    name { Faker::Lorem.word }
    entitlement { "urn:mace:x-aaf:dev:ide:#{Faker::Lorem.words(4).join(':')}" }
  end
end
