class CreatePosts < ActiveRecord::Migration[8.1]
  def change
    create_table :posts do |t|
      t.string :title
      t.string :slug
      t.text :content
      t.datetime :published_at
      t.datetime :edited_at
      t.integer :view_count

      t.timestamps
    end
    add_index :posts, :slug, unique: true
  end
end
