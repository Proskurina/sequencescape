#This file is part of SEQUENCESCAPE is distributed under the terms of GNU General Public License version 1 or later;
#Please refer to the LICENSE and README files for information on licensing and authorship of this file.
#Copyright (C) 2007-2011,2011,2012,2015 Genome Research Ltd.
module Cherrypick::VolumeByNanoGramsPerMicroLitre
  def volume_to_cherrypick_by_nano_grams_per_micro_litre(volume_required,concentration_required,source_concentration,minimum_volume=1)
    minimum_volume||=0
    check_inputs_to_volume_to_cherrypick_by_nano_grams_per_micro_litre!(volume_required,concentration_required,source_concentration)

    well_attribute.concentration    = concentration_required
    well_attribute.requested_volume = volume_required
    well_attribute.current_volume   = volume_required

    volume_to_pick = volume_required.ceil
    buffer_volume  = 0.0

    if !source_concentration.blank? && (source_concentration != 0.0) && !concentration_required.blank? && (concentration_required != 0.0)
      volume_to_pick = [[volume_required, ((volume_required*concentration_required)/source_concentration) ].min, minimum_volume].max
      buffer_volume  = buffer_volume_required(volume_required, volume_to_pick)
    end

    well_attribute.picked_volume  = volume_to_pick
    well_attribute.buffer_volume  = buffer_volume

    volume_to_pick
  end

  def check_inputs_to_volume_to_cherrypick_by_nano_grams_per_micro_litre!(volume_required,concentration_required,source_concentration)
    raise Cherrypick::VolumeError, "Volume required (#{volume_required.inspect}) is invalid for cherrypick by nano grams per micro litre"                      if volume_required.blank? || volume_required.to_f <= 0.0
    raise Cherrypick::ConcentrationError, "Concentration required (#{concentration_required.inspect}) is invalid for cherrypick by nano grams per micro litre" if concentration_required.blank? || concentration_required.to_f <= 0.0
    raise Cherrypick::ConcentrationError, "Source concentration (#{source_concentration.inspect}) is invalid for cherrypick by nano grams per micro litre"     if source_concentration.blank? || source_concentration.to_f < 0.0
  end
  private :check_inputs_to_volume_to_cherrypick_by_nano_grams_per_micro_litre!
end

