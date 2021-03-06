require 'csv'

class DatagroupsController < ApplicationController
  skip_before_filter :deny_access_to_all
  before_filter :load_datagroup, :except => [:index, :new, :create]

  access_control do
    actions :index, :show, :import_categories, :new, :create, :datacolumns do
      allow logged_in
    end
    actions :upload_categories, :update_categories, :edit, :update, :destroy do
      allow :admin, :data_admin
    end
  end

  def index
    validate_sort_params(collection: ['id', 'title', 'datacolumns_count', 'categories_count'], default: 'title')
    dgs = Datagroup.select('id, title, description, created_at, datacolumns_count,
                            (select count(*) from categories where datagroup_id = datagroups.id) as categories_count')
                   .order("#{params[:sort]} #{params[:direction]}").search(params[:search])
    respond_to do |format|
      format.html { @datagroups = dgs.paginate(page: params[:page], per_page: 100) }
      format.xml { @datagroups = dgs}
    end
  end

  def new
    @datagroup = Datagroup.new
  end

  def create
    @datagroup = Datagroup.new(params[:datagroup])
    if @datagroup.save
      flash[:notice] = "Data group '#{@datagroup.title}' was added successfully."
      redirect_to params[:import] ? new_datagroup_category_path(@datagroup) : @datagroup
    else
      render :new
    end
  end

  def show
    @datasets = @datagroup.datasets.select('datasets.id, datasets.title').order(:title).uniq
  end

  def update
    if @datagroup.update_attributes(params[:datagroup])
      redirect_to @datagroup, notice: "Successfully updated"
    else
      render :edit
    end
  end

  def destroy
    unless @datagroup.datasets.empty?
      flash[:error] = "Datagroup has associated datasets thus can't be deleted"
      redirect_to :back
    end
    if @datagroup.destroy
      redirect_to datagroups_path, :notice => "Deleted #{@datagroup.title}"
    else
      flash[:error] = @datagroup.errors.full_messages.to_sentence
      redirect_to :back
    end
  end

  # step 1 to batch update datagroup categories via CSV
  def upload_categories
  end

  # step 2 to batch update datagroup categories via CSV
  def update_categories
    if !params[:csvfile] then
      flash[:error] = "No File given"
      redirect_to :back and return
    end
    f = params[:csvfile][:file].path

    changes = @datagroup.update_and_merge_categories_with_csv(f, current_user)

    unless @datagroup.errors.empty?
      flash[:error] = @datagroup.errors.full_messages.to_sentence
      redirect_to :back and return
    else
      flash[:notice] = "#{changes[:u]} categories are updated and #{changes[:m]} categories are merged"
      redirect_to datagroup_path(@datagroup)
    end
  end

  def import_categories
    unless params[:csvfile]
      flash[:error] = "No File given"
      redirect_to :back and return
    end

    if @datagroup.import_categories_with_csv(params[:csvfile].path)
      redirect_to :back, :notice => 'Categories are successfully imported'
    else
      flash[:error] = @datagroup.errors.full_messages.to_sentence
      redirect_to :back
    end
  end

  def datacolumns
    respond_to do |format|
      format.html {
        @datacolumns = @datagroup.datacolumns.paginate(:page => params[:page], :per_page => 20, :order => "dataset_id, columnheader")
      }
      format.js { @headers = @datagroup.datacolumns.pluck(:columnheader) }
    end
  end

  private

  def load_datagroup
    @datagroup = Datagroup.find(params[:id])
  end

end
