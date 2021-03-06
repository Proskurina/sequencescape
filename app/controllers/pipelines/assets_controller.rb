# This file is part of SEQUENCESCAPE; it is distributed under the terms of
# GNU General Public License version 1 or later;
# Please refer to the LICENSE and README files for information on licensing and
# authorship of this file.
# Copyright (C) 2007-2011,2015 Genome Research Ltd.

# NOTE[xxx]: This controller may not be required but is here to support the Javascript used in the
# library prep pipeline.
class Pipelines::AssetsController < ApplicationController
  def new
    @asset, @family = Asset.new, Family.find(params[:family])
    render partial: 'descriptor', locals: { field: Descriptor.new, field_number: params[:id] }
  end
end
