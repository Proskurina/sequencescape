# This file is part of SEQUENCESCAPE; it is distributed under the terms of
# GNU General Public License version 1 or later;
# Please refer to the LICENSE and README files for information on licensing and
# authorship of this file.
# Copyright (C) 2007-2011,2015 Genome Research Ltd.

module ModelExtensions::SampleTube
  def self.included(base)
    base.class_eval do
      has_many :library_tubes, through: :links_as_parent, source: :descendant
    end
  end
end
