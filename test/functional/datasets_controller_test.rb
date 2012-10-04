require 'test_helper'
require 'fileutils'
require 'libxml'


class DatasetsControllerTest < ActionController::TestCase
  setup :activate_authlogic

  # because the update of a datacolumns datatype in test "quick approve updates datacolumn properties" calls some
  # sql statement in Datacolumn.add_data_values(user) which is conflicting with the dafault rails test transactions
  self.use_transactional_fixtures = false

  test "should get show dataset" do
    get :show, {:id => Dataset.first.id}
    assert_success_no_error
  end

  test "should show eml metadata as xml" do
    get :show, {:id => Dataset.first.id, :format => :eml}
    assert_success_no_error
  end

  test "eml is valid" do
    get :show, {:id => Dataset.last, :format => :eml}
    dataset_as_eml = LibXML::XML::Document.string(@response.body)
    eml_schema = LibXML::XML::Schema.new("test/fixtures/test_files_for_eml/eml-2.1.0/eml.xsd")

    assert dataset_as_eml.validate_schema(eml_schema)
  end

  test "dataset can be downloaded" do
    login_nadrowski
    ds = Dataset.find_by_title "Test species name import second version"

    get :download, :id => ds.id
    assert_success_no_error
  end

  test "unlogged-in visitors can only download free_for_public datasets" do
    ds = Dataset.find_by_title "Test species name import second version"
    assert !ds.free_for_public?
    get :download, :id => ds.id
    assert_match(/Access denied/, flash[:error])

    flash.delete(:error)

    ds_public = Dataset.find_by_title("TITLE: use for visual testing of export")

    assert ds_public.free_for_public?
    get :download, :id => ds_public.id
    assert_nil flash[:error]
  end


  test "members can download free for members datasets" do
    user = User.find_by_login "Phdstudentnutrientcycling"
    login_user user.login
    ds = Dataset.find_by_title "Test species name import second version"

    assert ds.free_for_members && !user.has_roles_for?(ds)
    get :download, :id => ds.id
    assert_nil flash[:error]
  end

  test "members cann't download datasets not free for members" do
    user = User.find_by_login "Phdstudentnutrientcycling"
    login_user user.login
    ds = Dataset.find_by_title "Test species name import"
    #make sure the dataset is not free for members and user has no role about it.
    assert !(ds.free_for_members  || ds.free_for_public|| user.has_roles_for?(ds))
    get :download, :id=>ds.id
    assert_match(/Access denied/, flash[:error])
  end

  test "members can not download datasets belonging to other projects only" do
    user = User.find_by_login("Pidata")
    login_user user.login
    ds = Dataset.find_by_title "Unit tests"
    assert_not_equal user.projects, ds.projects
    assert !(ds.free_for_members || ds.free_for_public || user.has_roles_for?(ds))

    get :download, :id=>ds.id
    assert_match(/Access denied/, flash[:error])
  end
  
  # Approval
  
  test "approve shows table for all datacolumns" do
    login_nadrowski
    dataset = Dataset.find 5

    get :approve, :id => dataset.id

    assert_success_no_error
    assert_select 'tbody tr', :count => dataset.datacolumns.count
  end

  test "auto approve works" do
    login_nadrowski
    dataset = Dataset.find 8
    @request.env['HTTP_REFERER'] = approve_dataset_url(dataset)
    assert_not_empty dataset.predefined_columns

    post :approve_predefined, :id => dataset.id

    assert :success
    assert_empty Dataset.find(dataset.id).predefined_columns
    assert_equal Datacolumn.find(53).import_data_type, 'text'
  end

  test "quick approve is displaying all select boxes" do
    login_nadrowski
    dataset = Dataset.find 5

    get :approval_quick, :id => dataset.id
    assert_select '.quick-approve-table select', :count => dataset.datacolumns.count*2
  end

  test "quick approve updates datacolumn properties" do
    login_nadrowski
    dataset = Dataset.find 5
    datacolumn_1_id = 33
    datagroup_1_id = 5
    datacolumn_2_id = 35
    datatype_2 = 'text'

    post :batch_update_columns, {:id => dataset.id,
            :datacolumn => [{:id => datacolumn_1_id, :datagroup => datagroup_1_id},
                            {:id => datacolumn_2_id, :import_data_type => datatype_2}]}

    assert_equal datagroup_1_id, Datacolumn.find(datacolumn_1_id).datagroup.id
    assert_equal datatype_2, Datacolumn.find(datacolumn_2_id).import_data_type.to_s

    assert_match /2/, flash[:notice]
  end

  test "quick approve works only for the dataset columns" do
    login_nadrowski
    dataset = Dataset.find 5
    datacolumn_id = 62
    post :batch_update_columns, {:id => dataset.id,
                                 :datacolumn => [{:id => datacolumn_id, :import_data_type => 'text'}]}

    assert_not_equal Datacolumn.find(datacolumn_id).import_data_type, 'text'
  end
  
  # Destroy
  
  test "destroy should delete a dataset" do
    pending "Implement me!"  
  end

  test "replacing original research data with new file" do

    FileUtils.copy("#{Rails.root}/files/4_8346952459374534species first test.xls",
                     "#{Rails.root}/files/4_8346952459374534species first test.xls.tmp")
    login_nadrowski
    @dataset = Dataset.first

    old_workbook = @dataset.datacolumns.map(&:columnheader)

    #upload the same workbook again. This should not cause error.
    assert_nothing_raised {
      post :delete_imported_research_data_and_file, :id => @dataset.id,
             :datafile => {
                 :file =>  Rack::Test::UploadedFile.new("#{Rails.root}/files/4_8346952459374534species first test.xls")
             }
    }
    assert_nil flash[:error]
    assert_redirected_to dataset_path(@dataset)
    @dataset.reload
    assert_equal Dataworkbook.new(@dataset.upload_spreadsheet).columnheaders_raw,old_workbook


    #upload another workbook
    post :delete_imported_research_data_and_file, :id => @dataset.id,
          :datafile => {
              :file => fixture_file_upload("test_files_for_uploads/SP5_TargetSpecies_CN_final_8_target_spec_kn_-_short.xls")
          }

    assert_redirected_to dataset_path(@dataset)

    @dataset.reload
    assert_not_equal Dataworkbook.new(@dataset.upload_spreadsheet).columnheaders_raw, old_workbook

    #clean and recover
    @dataset.upload_spreadsheet.destroy
    FileUtils.copy("#{Rails.root}/files/4_8346952459374534species first test.xls.tmp",
                     "#{Rails.root}/files/4_8346952459374534species first test.xls")
  end

  test "should show new dataset page" do
    login_nadrowski
    get :new
    assert_success_no_error
  end


end
