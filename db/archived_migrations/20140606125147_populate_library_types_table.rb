#This file is part of SEQUENCESCAPE is distributed under the terms of GNU General Public License version 1 or later;
# Please refer to the LICENSE and README files for information on licensing and
# authorship of this file.
# Copyright (C) 2014 Genome Research Ltd.
class PopulateLibraryTypesTable < ActiveRecord::Migration

  class LibraryType < ActiveRecord::Base; end

  def self.up
    ActiveRecord::Base.transaction do
      LibraryType.create!(existing_library_types.map {|name| {:name=>name} })
    end
  end

  def self.down
    ActiveRecord::Base.transaction do
      LibraryType.where(name: existing_library_types).each(&:destroy)
    end
  end

  def self.existing_library_types
    [
      "No PCR", "High complexity and double size selected", "Illumina cDNA protocol",
      "Agilent Pulldown", "Custom", "High complexity", "ChiP-seq", "NlaIII gene expression",
      "Standard", "Long range", "Small RNA", "Double size selected", "DpnII gene expression",
      "TraDIS", "qPCR only", "Pre-quality controlled", "DSN_RNAseq", "RNA-seq dUTP",
      "Manual Standard WGS (Plate)", "ChIP-Seq Auto", "TruSeq mRNA (RNA Seq)", "Small RNA (miRNA)",
      "RNA-seq dUTP eukaryotic", "RNA-seq dUTP prokaryotic", "No PCR (Plate)"
    ]
  end
end
