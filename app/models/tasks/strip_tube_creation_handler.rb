module Tasks::StripTubeCreationHandler

  def render_strip_tube_creation_task(task,params)

    @tubes_requested = @batch.requests.first.asset.requests.for_pipeline(task.workflow.pipeline).count
    @tubes_available = @batch.requests.first.asset.requests.for_pipeline(task.workflow.pipeline).pending.count

    strip_count = task.descriptors.find_by_key!('strips_to_create')

    @options = strip_count.selection.select {|v| v <= (@tubes_available)}
    @default = strip_count.value || @options.last
  end

  def do_strip_tube_creation_task(task,params)
    tubes_to_create = params['tubes_to_create'].to_i

    locations_requests = @batch.requests.with_asset_location.pending.group_by {|r| r.asset.map.column_order }

    if locations_requests.any? {|k,v| v.count < tubes_to_create }
      flash[:error] = "There are insufficient requests remaining for the requested number of tubes."
      flash[:error].concat(" Some wells of the plate have different numbers of requests.") if locations_requests.values.map(&:count).uniq.count > 1
      return false
    end

    if locations_requests.keys.sort != [0,1,2,3,4,5,6,7]
      flash[:error] = "This pipeline only supports wells in the first column."
      return false
    end

    source_plate = @batch.requests.first.asset.plate.stock_plate||@batch.requests.first.asset.plate
    base_name = source_plate.sanger_human_barcode

    strip_purpose = Purpose.find_by_name(task.descriptors.find_by_key!('strip_tube_purpose').value)

    (0...tubes_to_create).each do |tube_number|

      tube = strip_purpose.create!(:name=>"#{base_name}:#{tube_number+1}-#{@batch.id}")
      AssetLink::Job.create(source_plate,[tube])

      tube.size.times do |index|
        request = locations_requests[index].pop
        well    = tube.wells.in_column_major_order.all[index].id
        request.submission.next_requests(request).each do |dsr|
          dsr.request.update_attributes!(:asset_id => well)
        end
        request.update_attributes!(:target_asset_id => well)
      end
    end

    locations_requests.values.flatten.each do |request|
      @batch.remove_link(request)
      request.return_pending_to_inbox!
    end

    true
  end


end