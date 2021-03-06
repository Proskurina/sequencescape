#This file is part of SEQUENCESCAPE is distributed under the terms of GNU General Public License version 1 or later;
# Please refer to the LICENSE and README files for information on licensing and
# authorship of this file.
# Copyright (C) 2012 Genome Research Ltd.
class AddConstrainstsToBillingEvent < ActiveRecord::Migration
  def self.up
    ActiveRecord::Base.transaction do
      change_column(:billing_events, :request_id, :integer, :null => false)
    end
  end

  def self.down
    ActiveRecord::Base.transaction do
      change_column(:billing_events, :request_id, :integer, :null => true)
    end
  end
end
