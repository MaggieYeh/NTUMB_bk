class TranslatePageModel < ActiveRecord::Migration
  def up
    Page.create_translation_table!(
        {:menu_title => :string, :title => :string, :content => :text},
        {:migrate_data => true}
    )
  end

  def down
    Page.drop_translation_table! :migrate_data => true
  end
end
