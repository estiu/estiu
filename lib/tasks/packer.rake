def rebuild role
  puts "Building image for role #{role}..."
  base_ami = (role.to_s == AwsOps::BASE_IMAGE_NAME) ?
    AwsOps::Infrastructure.clean_ubuntu_ami(AwsOps::BUILD_SIZE) :
    AwsOps::Infrastructure.latest_ami(role, AwsOps::BUILD_SIZE)
  repo_source = ci? ? "~/clone" : "~/events"
  return system %| \
    set -e \
    set -u \
    cd packer/#{role}; \
    packer build \
      -var "base_ami=#{base_ami}" \
      -var "aws_access_key=$AWS_ACCESS_KEY" \
      -var "aws_secret_key=$AWS_SECRET_KEY" \
      -var "REPO_DEPLOY_PUBLIC_KEY=$REPO_DEPLOY_PUBLIC_KEY" \
      -var "REPO_DEPLOY_PRIVATE_KEY=$REPO_DEPLOY_PRIVATE_KEY" \
      -var "repo_source=$(echo #{repo_source})" \
      -var "instance_type=#{AwsOps::BUILD_SIZE}" \
      -var "user=#{AwsOps::USERNAME}" \
      -var "region=#{AwsOps::REGION}" \
      target.json ;\
    cd - \
  |
end

task packer: :environment do
  
  build_commit_count = 1 # sometimes one pushes more than one commit, only the last one gets built
  
  command = "git diff --name-only HEAD~#{build_commit_count}..HEAD"
  files = ['packer/base', 'lib/tasks/packer.rake', 'Gemfile*']
  no_base_built = AwsOps::Infrastructure.latest_ami(:base, AwsOps::BUILD_SIZE) == AwsOps::Infrastructure.clean_ubuntu_ami(AwsOps::BUILD_SIZE)
  
  rebuild_base = files.map{|f| `#{command} #{f}` }.any?(&:present?) || no_base_built
  
  (rebuild_base ? rebuild(:base) : true) &&
  rebuild(:web) &&
  rebuild(:worker) &&
  AwsOps::Infrastructure.delete_old_amis
  
end
