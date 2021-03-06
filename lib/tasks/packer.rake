require_relative '../../app/lib/aws_ops.rb'

def all_image_types
  AwsOps::IMAGE_TYPES
end

def rebuild role, rails_environment
  puts "Building image for role #{role}..."
  base_ami = (role.to_s == AwsOps::BASE_IMAGE_NAME) ?
    AwsOps::Amis.clean_ubuntu_ami(AwsOps::BUILD_SIZE) :
    AwsOps::Amis.latest_ami(AwsOps::BASE_IMAGE_NAME, AwsOps::BUILD_SIZE)
  repo_source = ci? ? "~/clone" : "~/estiu"
  return system %| \
    set -e \;
    set -u \;
    cd packer/#{role}; \
    packer build \
      -var "base_ami=#{base_ami}" \
      -var "aws_access_key=#{AwsOps::Permanent.credentials[:access_key_id]}" \
      -var "aws_secret_key=#{AwsOps::Permanent.credentials[:secret_access_key]}" \
      -var "REPO_DEPLOY_PUBLIC_KEY=$REPO_DEPLOY_PUBLIC_KEY" \
      -var "REPO_DEPLOY_PRIVATE_KEY=$REPO_DEPLOY_PRIVATE_KEY" \
      -var "repo_source=$(echo #{repo_source})" \
      -var "instance_type=#{AwsOps::BUILD_SIZE}" \
      -var "user_data_file=#{File.join(Rails.root, 'packer', 'base', 'user_data')}" \
      -var "ssh_keypair_name=#{AwsOps::KEYPAIR_NAME}" \
      -var "ssh_private_key_file=/Users/vemv/.ssh/eu_west_1.pem" \
      -var "user=#{AwsOps::USERNAME}" \
      -var "region=#{AwsOps::Permanent.region}" \
      -var "commit_sha=#{AwsOps::Permanent.current_commit}" \
      -var "RAILS_ENV=#{rails_environment}" \
      target.json ;\
    cd - \
  |
end

def build force_rebuild, images, environment
  
  build_commit_count = 1 # sometimes one pushes more than one commit, only the last one gets built
  
  command = "git diff --name-only HEAD~#{build_commit_count}..HEAD"
  files = ['packer/base', 'lib/tasks/packer.rake', 'Gemfile*']
  no_base_built = AwsOps::Amis.latest_ami(:base, AwsOps::BUILD_SIZE) == AwsOps::Amis.clean_ubuntu_ami(AwsOps::BUILD_SIZE)
  latest_ami_object = AwsOps::Amis.latest_ami_object(:base, AwsOps::BUILD_SIZE)
  
  rebuild_base = if force_rebuild
      true
    elsif latest_ami_object.tags.detect{|tag| tag.key == 'commit' && tag.value == AwsOps::Permanent.current_commit }
      false
    elsif files.map{|f| `#{command} #{f}` }.any?(&:present?)
      puts "Will build base because one of the following has changed: #{files}"
      true
    elsif no_base_built
      puts "Will build base because no existing base image could be found."
      true
    end
  
  all_good = true
  
  images.each_with_index do |image, i| # XXX parallel building of non-base images.
    
    fail if i.zero? && image != AwsOps::BASE_IMAGE_NAME # ensure ordering
    
    all_good = if image == AwsOps::BASE_IMAGE_NAME
      (rebuild_base ? rebuild(image, environment) : true)
    else
      rebuild(image, environment)
    end
    
    all_good || fail # prevent additional builds
    
  end
  
  if all_good
    AwsOps::Amis.delete_amis
  else
    exit 1
  end
  
end

namespace :packer do
  
  %i(production staging).each do |environment|
    
    set_task = "set_#{environment}_environment".to_sym
    
    task set_task => :environment do
      AwsOps.aws_ops_environment = environment
    end
    
    task environment => set_task do
      build(false, all_image_types, environment)
    end
    
    namespace environment do
          
      task rebuild: set_task do
        build :force_rebuild, all_image_types, environment
      end
        
      AwsOps::IMAGE_TYPES.each do |image|
        
        task("rebuild_#{image}".to_sym => set_task) do
          build (image == AwsOps::BASE_IMAGE_NAME), [AwsOps::BASE_IMAGE_NAME, image], environment
        end
        
      end
      
      task clear: set_task do
        AwsOps::Amis.delete_amis
      end
      
      task clear_all: set_task do
        AwsOps::Amis.delete_amis :all
      end
      
    end
    
  end
  
end
