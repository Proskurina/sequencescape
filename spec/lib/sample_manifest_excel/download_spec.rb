require 'rails_helper'

RSpec.describe SampleManifestExcel::Download, type: :model, sample_manifest_excel: true do

  attr_reader :download, :spreadsheet

  let(:test_file) { 'test.xlsx' }

  def save_file
    download.save(test_file)
    @spreadsheet = Roo::Spreadsheet.open(test_file)
  end


  before(:each) do
    SampleManifestExcel.configure do |config|
      config.folder = File.join('spec', 'data', 'sample_manifest_excel')
      config.load!
    end

    barcode = double('barcode')
    allow(barcode).to receive(:barcode).and_return(23)
    allow(PlateBarcode).to receive(:create).and_return(barcode)
  end

  it 'should not be valid without a sample manifest' do
    download = SampleManifestExcel::Download.new(nil,
      SampleManifestExcel.configuration.columns.plate_full.dup,
      SampleManifestExcel.configuration.ranges.dup)
    expect(download).to_not be_valid
  end

  it 'should not be valid without some columns' do
    download = SampleManifestExcel::Download.new(create(:sample_manifest), nil,
      SampleManifestExcel.configuration.ranges.dup)
    expect(download).to_not be_valid
  end

  it 'should not be valid without some ranges' do
    download = SampleManifestExcel::Download.new(create(:sample_manifest),
      SampleManifestExcel.configuration.columns.plate_full.dup, nil)
    expect(download).to_not be_valid
  end

  context 'Plate download' do
    before(:each) do
      sample_manifest = create(:sample_manifest, rapid_generation: true)
      sample_manifest.generate
      @download = SampleManifestExcel::Download.new(sample_manifest,
        SampleManifestExcel.configuration.columns.plate_full.dup, SampleManifestExcel.configuration.ranges.dup)
      save_file
    end

    it 'creates an excel file' do
      expect(File.file?(test_file)).to be_truthy
    end

    it 'creates the two different types of worksheet' do
      expect(spreadsheet.sheets.first).to eq('DNA Collections Form') 
      expect(spreadsheet.sheets.last).to eq('Ranges') 
    end

    it 'have the correct number of columns' do
      expect(download.column_list.count).to eq(SampleManifestExcel.configuration.columns.plate_full.count) 
    end
  end

  context 'Tube download' do
    setup do
      sample_manifest = create(:tube_sample_manifest)
      sample_manifest.generate
      @download = SampleManifestExcel::Download.new(sample_manifest,
        SampleManifestExcel.configuration.columns.tube_full.dup, SampleManifestExcel.configuration.ranges.dup)
      save_file
    end

    it 'creates an excel file' do
      expect(File.file?(test_file))
    end

    it 'creates the two different types of worksheet' do
      expect(spreadsheet.sheets.first).to eq('DNA Collections Form') 
      expect(spreadsheet.sheets.last).to eq('Ranges') 
    end

    it 'have the correct number of columns' do
      expect(download.column_list.count).to eq(SampleManifestExcel.configuration.columns.tube_full.count) 
    end
  end

  context 'Multiplexed library tube download' do
    setup do
      sample_manifest = create(:tube_sample_manifest, asset_type: 'multiplexed_library')
      sample_manifest.generate
      @download = SampleManifestExcel::Download.new(sample_manifest,
        SampleManifestExcel.configuration.columns.tube_multiplexed_library.dup, SampleManifestExcel.configuration.ranges.dup)
      save_file
    end

    it 'create an excel file' do
      expect(File.file?('test.xlsx')).to be_truthy
    end

    it 'create the two different types of worksheet' do
      expect(spreadsheet.sheets.first).to eq('DNA Collections Form') 
      expect(spreadsheet.sheets.last).to eq('Ranges')
    end

    it 'have the correct number of columns' do
      expect(download.column_list.count).to eq(SampleManifestExcel.configuration.columns.tube_multiplexed_library.count) 
    end
  end

  after(:each) do
    File.delete(test_file) if File.exist?(test_file)
    SampleManifestExcel.reset!
  end
end