#This file is part of SEQUENCESCAPE; it is distributed under the terms of GNU General Public License version 1 or later;
#Please refer to the LICENSE and README files for information on licensing and authorship of this file.
#Copyright (C) 2007-2011,2012,2015 Genome Research Ltd.

require "test_helper"

# Re-raise errors caught by the controller.
class SearchesController; def rescue_action(e) raise e end; end

class SearchesControllerTest < ActionController::TestCase
  context "Searches controller" do
    setup do
      @controller = SearchesController.new
      @request    = ActionController::TestRequest.new
      @response   = ActionController::TestResponse.new
    end

    should_require_login

    context "searching (when logged in)" do
      setup do
        @user =FactoryGirl.create :user
        @controller.stubs(:logged_in?).returns(@user)
        @controller.stubs(:current_user).returns(@user)

        @study                    =FactoryGirl.create :study, :name => "FindMeStudy"
        @study2                   =FactoryGirl.create :study, :name => "Another study"
        @sample                   =FactoryGirl.create :sample, :name => "FindMeSample"
        @asset                    =FactoryGirl.create(:sample_tube, :name => 'FindMeAsset')
        @asset_group_to_find      =FactoryGirl.create :asset_group, :name => "FindMeAssetGroup", :study => @study
        @asset_group_to_not_find  =FactoryGirl.create :asset_group, :name => "IgnoreAssetGroup"

      end
      context "#index" do

        context "with the valid search" do
          setup do
            get :index, :q => "FindMe"
          end

          should respond_with :success

          context "results" do
            define_method(:assert_link_to) do |url|
              assert_tag :tag => 'a', :attributes => { :href => url }
            end

            define_method(:deny_link_to) do |url|
              assert_no_tag :tag => 'a', :attributes => { :href => url }
            end

            should "contain a link to the study that was found" do
              assert_link_to study_path(@study)
            end

            should "not contain a link to the study that was not found" do
              deny_link_to study_path(@study2)
            end

            should "contain a link to the sample that was found" do
              assert_link_to sample_path(@sample)
            end

            should 'contain a link to the asset that was found' do
              assert_link_to asset_path(@asset)
            end

            should "contain a link to the asset_group that was found" do
              assert_link_to study_asset_group_path(@asset_group_to_find.study, @asset_group_to_find)
            end
          end
        end

        context "with a too short query" do
          setup do
            get :index, :q => "A"
          end

          should 'set the flash' do
            assert_equal 'Queries should be at least 3 characters long', @controller.flash.now[:error]
          end
        end
      end
    end
  end
end
