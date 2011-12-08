module DataworkbookFormat
  WBF = {
    # Version of File Format - Change when making changes here
    :wb_format_version => "0.0.0",

    # Spreadsheet formats
    :data_format    => Spreadsheet::Format.new(:size => 11, :horizontal_align => :left, :italic => true),
    :meta_format    => Spreadsheet::Format.new(:size => 11, :horizontal_align => :left, :color => 'brown'),
    :unapproved_format => Spreadsheet::Format.new(:size => 11, :horizontal_align => :left, :color => 'orange'),

    # Sheet numbers
    :metadata_sheet => 0,
    :people_sheet   => 1,
    :columns_sheet  => 2,
    :category_sheet => 3,
    :data_sheet     => 4,

    # Metadata sheet
    :meta_version_pos      => [0,4],
    :meta_title_pos        => [3,0],
    :meta_abstract_pos     => [6,0],
    :meta_comment_pos      => [9,0],
    :meta_projects_pos     => [11,1],
    :meta_owners_start_col => 1,
    :meta_owners_start_row => 14,

    :meta_usagerights_pos     => [22,0],
    :meta_published_pos       => [24,0],
    :meta_spatial_extent_pos  => [28,0],
    :meta_datemin_pos         => [32,0],
    :meta_datemax_pos         => [34,0],
    :meta_temporalextent_pos  => [36,0],
    :meta_taxonomicextent_pos => [39,0],
    :meta_design_pos          => [42,0],
    :meta_dataanalysis_pos    => [45,0],
    :meta_circumstances_pos   => [48,0],

    # Columns sheet
    :column_header_col      => 0,
    :column_definition_col  => 1,
    :column_unit_col        => 2,
    :column_missingcode_col => 3,
    :column_comment_col     => 4,

    :group_title_col             => 5,
    :group_description_col       => 6,
    :group_instrumentation_col   => 7,
    :group_informationsource_col => 8,
    :group_methodvaluetype_col   => 9,
    :group_timelatency_col       => 10,
    :group_timelatencyunit_col   => 11,

    # People sheet
    :people_columnheader_col  => 0,
    :people_firstname_col     => 1,
    :people_lastname_col      => 2,
    :people_projects_col      => 3,
    :people_roles_col         => 4,

    # Category sheet
    :category_columnheader_col => 0,
    :category_short_col        => 1,
    :category_long_col         => 2,
    :category_description_col  => 3
  }
end