# frozen_string_literal: true

require 'rails_helper'

require 'gumboot/shared_examples/subjects'

RSpec.describe Subject, type: :model do
  include_examples 'Subjects'

  context 'subject#permissions' do
    let(:subject) { FactoryBot.create(:subject) }
    let(:permission) { FactoryBot.create(:permission) }
    let(:role) { FactoryBot.create(:role) }

    it 'subject with no permissions' do
      expect(subject.permissions).to eq []
    end

    it 'subject with one role and permission' do
      role.permissions << permission
      subject.roles << role

      expect(subject.permissions).to eq [
        subject.roles.first.permissions.first.value
      ]
    end

    context 'subjects with multiple roles and permissions' do
      before do
        rand(1..10).times do
          r = FactoryBot.build(:role)
          rand(1..10).times do
            r.permissions << FactoryBot.build(:permission)
          end
          subject.roles << r
        end
      end

      it 'subject has multiple roles with multiple permissions' do
        res = []
        subject.roles.includes(:permissions).each do |result|
          result.permissions.each do |permission|
            res << permission.value
          end
        end

        expect(subject.permissions).to eq res
      end
    end
  end

  context 'subject#functioning?' do
    let(:subject) { FactoryBot.create(:subject) }
    context 'subject is functioning' do
      it 'is functioning' do
        expect(subject.functioning?).to eq true
      end
    end

    context 'subject is not functioning' do
      before { subject.enabled = false }
      it 'is not functioning' do
        expect(subject.functioning?).to eq false
      end
    end
  end

  describe '#valid_identifier_history?' do
    let(:subject) { Subject.create(attributes_for(:subject)) }

    let(:attrs) do
      Authentication::AttributeHelpers
        .federation_attributes(attributes_for(:shib_env)[:env])
    end

    before :each do
      create_federation_attributes
    end

    it 'is valid' do
      Snapshot.create_from_receiver(subject, attrs)
      Snapshot.create_from_receiver(subject, attrs)

      expect(subject.valid_identifier_history?).to eql true
    end

    it 'is invalid' do
      Snapshot.create_from_receiver(subject, attrs)
      Snapshot.create_from_receiver(
        subject,
        attrs.merge('HTTP_AUEDUPERSONSHAREDTOKEN' => '¯\_(ツ)_/¯')
      )

      expect(subject.valid_identifier_history?).to eql false
    end
  end
end
