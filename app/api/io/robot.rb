# This file is part of SEQUENCESCAPE; it is distributed under the terms of
# GNU General Public License version 1 or later;
# Please refer to the LICENSE and README files for information on licensing and
# authorship of this file.
# Copyright (C) 2014,2015 Genome Research Ltd.

class Io::Robot < ::Core::Io::Base
  set_model_for_input(::Robot)
  set_json_root(:robot)

  set_eager_loading { |model| model.include_properties }

  define_attribute_and_json_mapping("
                               name => name
                json_for_properties => robot_properties
  ")
end
