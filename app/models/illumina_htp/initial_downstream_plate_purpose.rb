#This file is part of SEQUENCESCAPE is distributed under the terms of GNU General Public License version 1 or later;
#Please refer to the LICENSE and README files for information on licensing and authorship of this file.
#Copyright (C) 2013 Genome Research Ltd.
class IlluminaHtp::InitialDownstreamPlatePurpose < IlluminaHtp::DownstreamPlatePurpose
  # Initial plates in the pulldown pipelines change the state of the pulldown requests they are being
  # created for to exactly the same state.
  def transition_to(plate, state, contents = nil, customer_accepts_responsibility = false)
    ActiveRecord::Base.transaction do
      super
      new_outer_state = ['started','passed','qc_complete','nx_in_progress'].include?(state) ? 'started' : state
      stock_wells(plate,contents).each do |source_well|
        source_well.requests.reject {|r| r.is_a?(TransferRequest)}.each do |request|
          request.transition_to(new_outer_state) if request.pending?
        end
      end
    end
  end

  def stock_wells(plate,contents)
    return plate.parent.wells unless contents.present?
    plate.parent.wells.located_at(contents)
  end

end
