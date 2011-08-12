class Admin::DatasetsController < Admin::AdminController
  #protect_from_forgery :only => [:create, :update, :delete]
  
  active_scaffold :dataset do |config|
    config.label = "DataSets"

    config.update.link.label = "Edit Data set"
    config.columns = [:id, :title, :filename, :download_counter, :destroy_me]
    config.update.columns = [:title, :finished, :visible_for_public,
                             :filename,
                             # :freeformats,
                             :abstract, :comment, :usagerights,
                             :published, :spatialextent, :datemin, :datemax,
                             :temporalextent, :taxonomicextent, :design,
                             :dataanalysis, :circumstances, :destroy_me ,:destroy_me_date]
  end
end
