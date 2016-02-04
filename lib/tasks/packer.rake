require_relative '../../app/lib/aws_ops.rb'

def all_image_types
  AwsOps::IMAGE_TYPES
end

def rebuild role, force_rebuild, rails_environment
  puts "Building image for role #{role}..."
  base_ami = (force_rebuild && role.to_s == AwsOps::BASE_IMAGE_NAME) ?
    AwsOps::Amis.clean_ubuntu_ami(AwsOps::BUILD_SIZE) :
    AwsOps::Amis.latest_ami(AwsOps::BASE_IMAGE_NAME, AwsOps::BUILD_SIZE)
  repo_source = ci? ? "~/clone" : "~/estiu"
  return system %| \
    set -e \;
    set -u \;
    cd packer/#{role}; \
    packer build \
      -var "base_ami=#{base_ami}" \
      -var "aws_access_key=$AWS_ACCESS_KEY" \
      -var "aws_secret_key=$AWS_SECRET_KEY" \
      -var "REPO_DEPLOY_PUBLIC_KEY=$REPO_DEPLOY_PUBLIC_KEY" \
      -var "REPO_DEPLOY_PRIVATE_KEY=$REPO_DEPLOY_PRIVATE_KEY" \
      -var "repo_source=$(echo #{repo_source})" \
      -var "instance_type=#{AwsOps::BUILD_SIZE}" \
      -var "user_data_file=#{File.join(Rails.root, 'packer', 'base', 'user_data')}" \
      -var "ssh_keypair_name=#{AwsOps::KEYPAIR_NAME}" \
      -var "ssh_private_key_file=/Users/vemv/.ssh/eu_west_1.pem" \
      -var "user=#{AwsOps::USERNAME}" \
      -var "region=#{AwsOps::REGION}" \
      -var "commit_sha=#{`git rev-parse HEAD`.split("\n")[0]}" \
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
  
  rebuild_base = force_rebuild || files.map{|f| `#{command} #{f}` }.any?(&:present?) || no_base_built
  
  all_good = true
  
  images.each_with_index do |image, i|
    
    fail if i.zero? && image != AwsOps::BASE_IMAGE_NAME # ensure ordering
    
    all_good = if image == AwsOps::BASE_IMAGE_NAME
      (rebuild_base ? rebuild(image, force_rebuild) : true)
    else
      rebuild(image, force_rebuild)
    end
    
    all_good || fail # prevent additional builds
    
  end
  
  if all_good
    AwsOps::Amis.delete_amis
  else
    exit 1
  end
  
end

%i(production staging).each do |environment|
    
  task packer: :environment do
    AwsOps.aws_ops_environment = environment
    build(false, all_image_types, environment)
  end

end

namespace :packer do
  
  %i(production staging).each do |environment|
    
    namespace environment do
          
      task rebuild: :environment do
        AwsOps.aws_ops_environment = environment
        build :force_rebuild, all_image_types, environment
      end
      
      (AwsOps::IMAGE_TYPES - [AwsOps::BASE_IMAGE_NAME]).each do |image|
        
        task("rebuild_#{image}".to_sym => :environment) do
          AwsOps.aws_ops_environment = environment
          build false, [AwsOps::BASE_IMAGE_NAME, image], environment
        end
        
      end
      
      task clear: :environment do
        AwsOps.aws_ops_environment = environment
        AwsOps::Amis.delete_amis
      end
      
      task clear_all: :environment do
        AwsOps.aws_ops_environment = environment
        AwsOps::Amis.delete_amis :all
      end
      
    end
    
  end
  
end
