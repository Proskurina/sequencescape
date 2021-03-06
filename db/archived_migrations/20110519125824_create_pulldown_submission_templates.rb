#This file is part of SEQUENCESCAPE is distributed under the terms of GNU General Public License version 1 or later;
# Please refer to the LICENSE and README files for information on licensing and
# authorship of this file.
# Copyright (C) 2011 Genome Research Ltd.
class CreatePulldownSubmissionTemplates < ActiveRecord::Migration
  SEQUENCING_REQUEST_TYPE_NAMES = [
    "Single ended sequencing",
    "Single ended hi seq sequencing",
    "Paired end sequencing",
    "HiSeq Paired end sequencing"
  ]

  REQUEST_TYPES_TO_DEFAULTS = {
    'Pulldown WGS' => { :library_type => 'Standard',         :fragment_size_required_from => '300', :fragment_size_required_to => '500' },
    'Pulldown SC'  => { :library_type => 'Agilent Pulldown', :fragment_size_required_from => '100', :fragment_size_required_to => '400' },
    'Pulldown ISC' => { :library_type => 'Agilent Pulldown', :fragment_size_required_from => '100', :fragment_size_required_to => '400' }
  }

  def self.up
    ActiveRecord::Base.transaction do
      workflow   = Submission::Workflow.find_by_key('short_read_sequencing') or raise StandardError, 'Cannot find Next-gen sequencing workflow'
      cherrypick = RequestType.find_by_name('Cherrypicking for Pulldown')    or raise StandardError, 'Cannot find Cherrypicking for Pulldown request type'

      REQUEST_TYPES_TO_DEFAULTS.each do |request_type_name, defaults|
        pulldown_request_type = RequestType.find_by_name(request_type_name) or raise StandardError, "Cannot find #{request_type_name.inspect}"

        RequestType.find_each(:conditions => { :name => SEQUENCING_REQUEST_TYPE_NAMES }) do |sequencing_request_type|
          submission                   = LinearSubmission.new
          submission.request_type_ids  = [ cherrypick.id, pulldown_request_type.id, sequencing_request_type.id ]
          submission.info_differential = workflow.id
          submission.workflow          = workflow
          submission.request_options   = defaults

          SubmissionTemplate.new_from_submission("Cherrypick for pulldown - #{request_type_name} - #{sequencing_request_type.name}", submission).save!
        end
      end
    end
  end

  def self.down
    ActiveRecord::Base.transaction do
      template_names = []
      SEQUENCING_REQUEST_TYPE_NAMES.each do |sequencing_name|
        REQUEST_TYPES.each do |request_type_name|
          template_names << "Cherrypick for pulldown - #{request_type_name} - #{sequencing_name}"
        end
      end

      SubmissionTemplate.destroy_all([ 'name IN (?)', template_names ])
    end
  end
end
