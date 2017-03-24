module SampleManifestExcel
  module SpecialisedField
    module Base
      extend ActiveSupport::Concern

      included do
        include ActiveModel::Model

        define_method :initialize do |_attributes = {}|
          super
        end
      end

      attr_accessor :value, :sample

      def update(_attributes = {})
      end
    end

    module SangerSampleIdValue
      def value=(sample)
        @value = sample.sanger_sample_id
      end
    end

    module ValueToInteger
      def value=(value)
        @value = value.to_i if value.present?
      end
    end

    module ValueRequired
      extend ActiveSupport::Concern

      included do
        validates_presence_of :value
      end
    end

    module Tagging
      extend ActiveSupport::Concern

      module ClassMethods
        def set_tag_name(name)
          define_method :tag_name do
            name
          end
        end
      end

      def update(attributes = {})
        if valid?
          tag = attributes[:tag_group].tags.find_or_create_by(oligo: value) do |t|
            t.map_id = attributes[:tag_group].tags.count + 1
          end

          attributes[:aliquot].send("#{tag_name}=", tag)
        end
      end
    end

    Dir[File.join(File.dirname(__FILE__), 'specialised_field', '*.rb')].each { |file| require file }
  end
end