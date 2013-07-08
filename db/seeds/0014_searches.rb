# Here are a load of searches that can be performed through the API.
Search::FindAssetByBarcode.create!(:name => 'Find assets by barcode')
Search::FindModelByName.create!(:name => 'Find project by name', :model_name => 'Project')
Search::FindModelByName.create!(:name => 'Find study by name',   :model_name => 'Study')
Search::FindModelByName.create!(:name => 'Find sample by name',  :model_name => 'Sample')
Search::FindSourceAssetsByDestinationAssetBarcode.create!(:name => 'Find source assets by destination asset barcode')
Search::FindUserByLogin.create!(:name => 'Find user by login')
Search::FindUserBySwipecardCode.create!(:name => 'Find user by swipecard code')
Search::FindPulldownPlates.create!(:name => 'Find pulldown plates')
Search::FindIlluminaBPlates.create!(:name=>'Find Illumina-B plates')
Search::FindIlluminaBPlatesForUser.create!(:name=>'Find Illumina-B plates for user')
Search::FindIlluminaBStockPlates.create!(:name=>'Find Illumina-B stock plates')
Search::FindOutstandingIlluminaBPrePcrPlates.create!(:name=>'Find outstanding Illumina-B pre-PCR plates')
Search::FindIlluminaBTubes.create!(:name=>'Find Illumina-B tubes')
Search::FindPulldownPlatesForUser.create!(:name=>'Find pulldown plates for user')
Search::FindPulldownStockPlates.create!(:name=>'Find pulldown stock plates')
Search::FindIlluminaAPlates.create!(:name=>'Find Illumina-A plates')
Search::FindIlluminaAStockPlates.create!(:name=>'Find Illumina-A stock plates')
