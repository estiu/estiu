def rebuild role
  puts "Building image for role #{role}..."
  system %| \
    cd packer/#{role}; \
    packer build \
      -var "base_ami=#{AwsOps::Infrastructure.latest_ami role}" \
      -var "aws_access_key=$AWS_ACCESS_KEY" \
      -var "aws_secret_key=$AWS_SECRET_KEY" \
      -var "REPO_DEPLOY_PUBLIC_KEY=$REPO_DEPLOY_PUBLIC_KEY" \
      -var "REPO_DEPLOY_PRIVATE_KEY=$REPO_DEPLOY_PRIVATE_KEY" \
      -var "repo_source=$(echo ~/events)" \
      -var "instance_type=#{AwsOps::CI_SIZE}" \
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
  
  rebuild_base = files.map{|f| `#{command} #{f}` }.any?(&:present?)
  
  rebuild(:base) if rebuild_base
  rebuild(:web)
  rebuild(:worker)
end
