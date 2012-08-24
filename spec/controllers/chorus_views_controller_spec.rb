require 'spec_helper'

describe ChorusViewsController, :database_integration => true do
  let(:account) { GpdbIntegration.real_gpdb_account }
  let(:database) { GpdbDatabase.find_by_name_and_instance_id(GpdbIntegration.database_name, GpdbIntegration.real_gpdb_instance)}
  let(:schema) { database.schemas.find_by_name('test_schema') }



  before do
    log_in account.owner
    refresh_chorus
  end

  context "#create" do
    let(:options) {
      HashWithIndifferentAccess.new(
          :query => "Select * from base_table1",
          :schema => schema.id,
          :name => "my_chorus_view"
      )
    }

    it "should create chorus view" do
      post :create, :chorus_view => options

      Dataset.chorus_views.last.name.should == "my_chorus_view"
      response.code.should == "201"
      response.body.should == "{}"
    end

    context "query is invalid" do
      let(:options) {
        HashWithIndifferentAccess.new(
            :query => "Select * from non_existing_table",
            :schema => schema.id,
            :name => "invalid_chorus_view"
        )
      }

      it "should handle error" do
        post :create, :chorus_view => options
        response.code.should == "422"
      end
    end

  end
end