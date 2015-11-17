# to upload the files from a local machine:
# aws s3api put-object --bucket events-env-vars --key .env --body .env
# aws s3api put-object --bucket events-env-vars --key .env.production --body .env.production

files = [".env", ".env.#{`cat /home/ec2-user/events/RAILS_ENV`.split("\n")[0]}"]
all_ok = true
files.each do |file|
  if all_ok
    all_ok = system "aws s3api get-object --bucket events-env-vars --key '#{file}' '#{file}'"
  else
    exit 1
  end
end