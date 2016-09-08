# frozen_string_literal: true

require 'authentication/attribute_helpers'

module Authentication
  class SubjectReceiver
    include ShibRack::DefaultReceiver
    include SuperIdentity::Client

    def map_attributes(env)
      Authentication::AttributeHelpers.federation_attributes(env)
    end

    def subject(_env, attrs)
      existing_attributes = FederationAttribute.existing_attributes(attrs)

      Subject.transaction do
        subject = Subject.create_from_receiver(existing_attributes)
        Snapshot.create_from_receiver(subject, existing_attributes)

        Authentication::SubjectReceiver.assign_entitlements(
          subject,
          entitlements(subject.auedupersonsharedtoken)
        )

        subject
      end
    end

    def finish(_env)
      redirect_to('/snapshots/latest')
    end

    # :nocov:
    def ide_config
      Rails.application.config.validator_service.ide
    end
    # :nocov:

    class << self
      def assign_entitlements(subject, values)
        assigned = values.map do |value|
          r = Role.find_by(entitlement: value)
          subject.roles << r unless subject.roles.include?(r)

          r
        end

        subject.subject_roles.where.not(role: assigned).destroy_all
      end
    end
  end
end
