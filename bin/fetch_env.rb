files = [".env", ".env.#{`cat RAILS_ENV`}"]
all_ok = true
files.each do |file|
  if all_ok
    all_ok = system "aws s3api get-object --bucket events-env-vars --key #{file} #{file}"
  else
    exit 1
  end
end