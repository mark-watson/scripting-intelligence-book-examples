require 'aws/s3'
require 'yaml'
require 'pp'

AWS::S3::Base.establish_connection!(:access_key_id => ENV['AMAZON_ACCESS_KEY_ID'],
                                    :secret_access_key => ENV['AMAZON_SECRET_ACCESS_KEY'])

# Print out all buckets in current use:
pp AWS::S3::Service.buckets

# create a bucket for this section's examples:
pp AWS::S3::Bucket.create('web3_chapter12')

examples_bucket = AWS::S3::Bucket.find('web3_chapter12')

AWS::S3::S3Object.store('FishFarm.pdf', open('/Users/markw/Sites/opencontent/FishFarm.pdf'), 'web3_chapter12')

pp examples_bucket.objects

# get raw data from S3:
pdf = AWS::S3::S3Object.find('FishFarm.pdf', 'web3_chapter12')
#  raw data is in:  picture.value

# read the PDF file stored in S3 back to the local file system:
open('/tmp/FishFarm.pdf', 'w') do |file|
  AWS::S3::S3Object.stream('FishFarm.pdf', 'web3_chapter12') { |data| file.write(data) }
end
  
# write a Ruby object to S3:
AWS::S3::S3Object.store('test ruby data 1', YAML.dump([1,2,3.14159,"test"]), 'web3_chapter12')

data = AWS::S3::S3Object.find('test ruby data 1', 'web3_chapter12')
pp YAML.load(data.value)

# clean up:
AWS::S3::S3Object.delete('test ruby data 1', 'web3_chapter12')
AWS::S3::S3Object.delete('FishFarm.pdf', 'web3_chapter12')
