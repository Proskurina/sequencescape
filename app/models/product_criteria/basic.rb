#This file is part of SEQUENCESCAPE is distributed under the terms of GNU General Public License version 1 or later;
#Please refer to the LICENSE and README files for information on licensing and authorship of this file.
#Copyright (C) 2015 Genome Research Ltd.
class ProductCriteria::Basic

  SUPPORTED_WELL_ATTRIBUTES = [:gel_pass, :concentration, :current_volume, :pico_pass, :gender_markers, :gender, :measured_volume, :initial_volume, :molarity]
  SUPPORTED_SAMPLE = [:sanger_sample_id]
  SUPPORTED_SAMPLE_METADATA = [:gender, :sample_ebi_accession_number, :supplier_name]
  EXTENDED_ATTRIBUTES = [:total_micrograms, :conflicting_gender_markers, :sample_gender]

  PASSSED_STATE = 'passed'
  FAILED_STATE = 'failed'

  attr_reader :passed, :params, :comment, :values
  alias_method :passed?, :passed

  Comparison = Struct.new(:method,:message)

  METHOD_ALIAS = {
    :greater_than => Comparison.new(:>,  '%s too low' ),
    :less_than    => Comparison.new(:<,  '%s too high'),
    :at_least     => Comparison.new(:>=, '%s too low' ),
    :at_most      => Comparison.new(:<=, '%s too high'),
    :equals       => Comparison.new(:==, '%s not suitable')
  }

  GENDER_MARKER_MAPS = {
    'male' => 'M',
    'female' => 'F'
  }

  class << self
    # Returns a list of possible criteria to either display or validate
    def available_criteria
      SUPPORTED_WELL_ATTRIBUTES + EXTENDED_ATTRIBUTES + SUPPORTED_SAMPLE_METADATA + SUPPORTED_SAMPLE
    end

    def headers(configuration)
      configuration.map {|k,v| k } + [:comment]
    end
  end

  def initialize(params,well)
    @params = params
    @well_or_metric = well
    @comment = []
    @values = {}
    assess!
  end

  def total_micrograms
    return nil if measured_volume.nil? || concentration.nil?
    (measured_volume * concentration) / 1000.0
  end

  def conflicting_gender_markers
    (gender_markers||[]).select {|marker| conflicting_marker?(marker)}.count
  end

  def metrics
    values.merge({:comment => @comment.join(';')})
  end

  SUPPORTED_SAMPLE.each do |attribute|
    delegate(attribute, :to => :sample)
  end

  delegate(:sample_metadata, :to => :sample)

  SUPPORTED_SAMPLE_METADATA.each do |attribute|
    delegate(attribute, :to => :sample_metadata)
  end

  SUPPORTED_WELL_ATTRIBUTES.each do |attribute|
    delegate(attribute, :to => :well_attribute)
  end

  # Return the sample gender, returns nil if it can't be determined
  # ie. mixed input, or not male/female
  def sample_gender
    markers = @well_or_metric.samples.map {|s| s.sample_metadata.gender.downcase.strip }.uniq
    return nil if markers.count > 1
    GENDER_MARKER_MAPS[markers.first]
  end

  def qc_decision
    passed? ? PASSSED_STATE : FAILED_STATE
  end

  private

  def well_attribute
    @well_or_metric.well_attribute
  end

  def sample
    @well_or_metric.sample
  end

  def conflicting_marker?(marker)
    expected = sample_gender
    return false if expected.nil?
    return false unless known_marker?(marker)
    marker != expected
  end

  def known_marker?(marker)
    GENDER_MARKER_MAPS.values.include?(marker)
  end

  def invalid(attribute,message)
    @passed = false
    @comment << message % attribute.to_s.humanize
  end

  def assess!
    @passed = true
    params.each do |attribute,comparisons|
      value = fetch_attribute(attribute)
      values[attribute] = value
      invalid(attribute,'%s has not been recorded') && next if value.nil? && comparisons.present?
      comparisons.each do |comparison,target|
        value.send(method_for(comparison),target) || invalid(attribute,message_for(comparison))
      end
    end
  end

  # If @well_or_metric is a hash, then we are re-assessing the original criteria
  #
  # Note: This gives us the result at the time the criteria were
  # originally run, and doesn't take into account subsequent changes
  # in the well. This is useful if the metric has gone through multiple manual states.
  # This probably won't get callled for the basic class, but may be used for subclasses
  def fetch_attribute(attribute)
    if @well_or_metric.is_a?(Hash)
      @well_or_metric[attribute]
    else
      self.send(attribute)
    end
  end

  def method_for(comparison)
    METHOD_ALIAS[comparison].method || raise(UnknownSpecification, "#{comparison} isn't a recognised means of comparison.")
  end

  def message_for(comparison)
    METHOD_ALIAS[comparison].message || raise(UnknownSpecification, "#{comparison} isn't a recognised means of comparison.")
  end

end
