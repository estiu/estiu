def rebuild role, force_rebuild
  puts "Building image for role #{role}..."
  base_ami = (force_rebuild && role.to_s == AwsOps::BASE_IMAGE_NAME) ?
    AwsOps::Infrastructure.clean_ubuntu_ami(AwsOps::BUILD_SIZE) :
    AwsOps::Infrastructure.latest_ami(AwsOps::BASE_IMAGE_NAME, AwsOps::BUILD_SIZE)
  repo_source = ci? ? "~/clone" : "~/events"
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
      target.json ;\
    cd - \
  |
end

def build force_rebuild=false
  
  build_commit_count = 1 # sometimes one pushes more than one commit, only the last one gets built
  
  command = "git diff --name-only HEAD~#{build_commit_count}..HEAD"
  files = ['packer/base', 'lib/tasks/packer.rake', 'Gemfile*']
  no_base_built = AwsOps::Infrastructure.latest_ami(:base, AwsOps::BUILD_SIZE) == AwsOps::Infrastructure.clean_ubuntu_ami(AwsOps::BUILD_SIZE)
  
  rebuild_base = force_rebuild || files.map{|f| `#{command} #{f}` }.any?(&:present?) || no_base_built
  
  all_good =
    (rebuild_base ? rebuild(:base, force_rebuild) : true) &&
    rebuild(:web, force_rebuild) &&
    rebuild(:worker, force_rebuild)
  
  if all_good
    AwsOps::Infrastructure.delete_amis
  else
    exit 1
  end
  
end

task packer: :environment do
  build
end

namespace :packer do
  
  task rebuild: :environment do
  
    build :force_rebuild
    
  end
  
  task clear: :environment do
    
    AwsOps::Infrastructure.delete_amis
    
  end
  
  task clear_all: :environment do
    
    AwsOps::Infrastructure.delete_amis :all
    
  end
  
end
