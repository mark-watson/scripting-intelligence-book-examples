require 'zip/zip' # may not be compatible with Ruby 1.9.1 (ftools dependency)
  
class CreateNameLinks < ActiveRecord::Migration
  def self.up
    create_table :name_links do |t|
      t.column :name, :string
      t.column :url,  :string
    end
    # read Hadoop mapreduce output files in the specified ZIP file:
    ActiveRecord::Base.transaction do
      Zip::ZipInputStream::open("db/mapreduce_results.zip") { |io|
        while (entry = io.get_next_entry)
          io.read.each_line {|line|
            name, urls = line.strip.split("\t")
            # Hadoop will make sure that all URLs for a given name are on the same line
            # so we can avoid a database lookup to prevent duplicates by simply
            # removing duplicates in the array 'urls':
            urls.split(" ").uniq.each {|url|
              NameLink.create(:name => name, :url => url) if name.length < 25
            }
          }
        end
      }
    end
  end

  def self.down
    drop_table :name_links
  end
end
