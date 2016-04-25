#This file is part of SEQUENCESCAPE; it is distributed under the terms of GNU General Public License version 1 or later;
#Please refer to the LICENSE and README files for information on licensing and authorship of this file.
#Copyright (C) 2007-2011,2012,2015,2016 Genome Research Ltd.

class CherrypickingPipeline < GenotypingPipeline

  def custom_inbox_actions
    [:holder_not_control]
  end

  def inbox_eager_loading
    :loaded_for_grouped_inbox_display
  end

end
