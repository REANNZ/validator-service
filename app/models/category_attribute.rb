# frozen_string_literal: true
class CategoryAttribute < ApplicationRecord
  belongs_to :category
  belongs_to :federation_attribute

  valhammer

  # :nocov:
  rails_admin do
    parent Category
  end
  # :nocov:
end
