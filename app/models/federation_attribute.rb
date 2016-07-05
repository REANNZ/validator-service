# frozen_string_literal: true
class FederationAttribute < ActiveRecord::Base
  has_many :attribute_values

  has_many :category_attributes
  has_many :categories, through: :category_attributes

  valhammer

  class << self
    def existing_headers
      select(:http_header).map(&:http_header)
    end

    def new_attributes?(keys)
      where(http_header: keys).count != keys.size
    end

    def new_attributes(attrs)
      headers = existing_headers

      attrs.keep_if { |k, _v| !headers.include?(k) }
    end

    def existing_attributes(attrs)
      headers = existing_headers

      attrs.keep_if { |k, _v| headers.include?(k) }
    end
  end
end
