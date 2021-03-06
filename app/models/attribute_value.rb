# frozen_string_literal: true

class AttributeValue < ApplicationRecord
  has_many :snapshot_attribute_values, dependent: :destroy
  belongs_to :federation_attribute

  valhammer

  class << self
    def validation_state(category, federation_attribute, attribute_value)
      if attribute_value
        valid_response(federation_attribute, attribute_value)
      else
        required_response(category, federation_attribute)
      end
    end

    def valid_response(federation_attribute, attribute_value)
      if federation_attribute.regexp && !Regexp.new(federation_attribute.regexp).match?(attribute_value)
        return ApplicationHelper::ResponseFor.invalid_attribute if federation_attribute.regexp_triggers_failure?

        return ApplicationHelper::ResponseFor.imperfect_attribute
      end

      ApplicationHelper::ResponseFor.valid_attribute
    end

    def required_response(category, federation_attribute)
      if category.category_attributes
                 .find_by(federation_attribute: federation_attribute)
                 .try(:presence?)
        ApplicationHelper::ResponseFor.required_attribute
      else
        ApplicationHelper::ResponseFor.not_supplied_attribute
      end
    end
  end

  # :nocov:
  rails_admin do
    visible false

    object_label_method do
      :custom_label_method
    end
  end
  # :nocov:

  def custom_label_method
    value
  end
end
