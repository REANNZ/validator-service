# frozen_string_literal: true
require 'rails_helper'

require 'gumboot/shared_examples/api_subjects'

RSpec.describe APISubject, type: :model do
  include_examples 'API Subjects'
end
