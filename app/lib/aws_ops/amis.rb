module AwsOps
  class Amis
    
    extend AwsOps
    
    def self.clean_ubuntu_ami size
      # I think all these sizes are fine with the same AMI, but larger need a different ubuntu image.
      ami1 = 'ami-47a23a30'
      Hash.new { raise }.merge({
        't2.micro' => ami1,
        't2.small' => ami1,
        't2.medium' => ami1
      })[size]
    end
    
    def self.latest_ami_object role, size
      latest = ec2_client.describe_images(owners: ['self']).images.
        select{|image|
          (image.tags.detect{|tag| tag.key == 'type' && tag.value == role.to_s }) &&
          (image.tags.detect{|tag| tag.key == 'environment' && tag.value == environment })
        }.sort {|a, b|
          DateTime.iso8601(a.creation_date) <=> DateTime.iso8601(b.creation_date)
        }.
        last
      if latest
        latest
      else
        if role.to_s == BASE_IMAGE_NAME
          Struct.new(:image_id).new(clean_ubuntu_ami size)
        else
          latest_ami BASE_IMAGE_NAME, size
        end
      end

    end
    
    def self.latest_ami role=BASE_IMAGE_NAME, size
      latest_ami_object(role, size).image_id
    end
    
    def self.delete_amis newer_too=false
      IMAGE_TYPES.each do |role|
        images = ec2_client.describe_images(owners: ['self']).images.
        select{|image|
          image.tags.detect{|tag|
            (tag.key == 'type' && tag.value == role.to_s) &&
            (tag.key == 'environment' && tag.value == environment)
          }
        }.sort {|a, b|
          DateTime.iso8601(a.creation_date) <=> DateTime.iso8601(b.creation_date)
        }
        target = newer_too ? images : images[0...(images.size - 1)]
        target.each do |image|
          puts "Deregistering #{image.image_id}"
          ec2_client.deregister_image({image_id: image.image_id})
          ec2_client.delete_snapshot({snapshot_id: image.block_device_mappings.detect(&:ebs).ebs.snapshot_id})
        end
      end
    end
    
  end
end