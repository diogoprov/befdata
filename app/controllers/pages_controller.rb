class PagesController < ApplicationController

  skip_before_filter :deny_access_to_all
  access_control do
    actions :home, :imprint, :help, :data, :search do
      allow all
    end
  end

  def home
  end

  def imprint
    @external_usages = [
      ['Rails','http://rubyonrails.org/'],
      ['Rake','http://rake.rubyforge.org/'],
      ['Pg','https://bitbucket.org/ged/ruby-pg'],
      ['Haml','http://haml-lang.com/'],
      ['Authlogic','https://github.com/binarylogic/authlogic'],
      ['Acl9','https://github.com/be9/acl9'],
      ['Dynamic_form','https://github.com/rails/dynamic_form'],
      ['Paperclip','https://github.com/thoughtbot/paperclip'],
      ['Acts-as-taggable-on','https://github.com/mbleigh/acts-as-taggable-on'],
      ['Spreadsheet','http://spreadsheet.rubyforge.org/'],
      ['Yaml_db','https://github.com/ludicast/yaml_db'],
      ['Delayed_job','https://github.com/collectiveidea/delayed_job'],
      ['Daemons','http://daemons.rubyforge.org/'],
      ['Whenever','https://github.com/javan/whenever/'],
      ['Test-unit','http://test-unit.rubyforge.org/'],
      ['Ruby-prof','http://ruby-prof.rubyforge.org/'],
      ['PostgreSQL','http://www.postgresql.org/'],
      ['JQuery','http://jquery.org/'],
      ['JQuery Tablesorter','http://tablesorter.com/'],
      ['JQuery UI','http://jqueryui.com/'],
      ['SimpleModal','http://www.ericmmartin.com/projects/simplemodal/'],
      ['Blueprint CSS','http://blueprintcss.org/'],
      ['Pg_Search', 'https://github.com/Casecommons/pg_search'],
      ['select2', 'http://ivaynberg.github.com/select2']
    ]
  end

  # This method is the dashboard method of our Portal
  # This provide a first look to our metadata and give a hint about our data
  def data
    @tags = DatasetTag.tag_counts
    @datasets = Dataset.search(params[:q], search_option_params).paginate(page: params[:page], per_page: 25).records
  end
  
private
  def search_option_params
    options = {}

    # sorting
    if params[:sort]
      sort = params[:sort].split('-')
      case sort[0]
        when 'relevance'
          # when executing full text search, relevance is the default sorting method,
          # so it's not neccessary to spefify it.
          ;
        when 'title'
          options[:sort] = {"title.raw" => sort[1]}
        else
          options[:sort] = {sort[0] => sort[1]}
      end
    end
    options
  end
end
