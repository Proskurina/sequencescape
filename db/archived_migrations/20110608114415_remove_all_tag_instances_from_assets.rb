#This file is part of SEQUENCESCAPE is distributed under the terms of GNU General Public License version 1 or later;
# Please refer to the LICENSE and README files for information on licensing and
# authorship of this file.
# Copyright (C) 2011 Genome Research Ltd.
class RemoveAllTagInstancesFromAssets < ActiveRecord::Migration
  def self.up
    ActiveRecord::Base.transaction do
      # Delete all rows from the asset_links and assets table that reference TagInstance instances.
      ActiveRecord::Base.connection.update(%Q{
        DELETE asset_links, assets
        FROM asset_links, assets
        WHERE asset_links.ancestor_id=assets.id AND assets.sti_type="TagInstance"
      })
    end
  end

  def self.down
    # You'd think it was just a case of attaching a TagInstance as a parent of any asset that contains
    # aliquots with tags, but it's not, and that would generate far, far, more than existed previously.
    raise ActiveRecord::IrreversibleMigration, "Cannot put back tag instances without a lot of work"
  end
end
