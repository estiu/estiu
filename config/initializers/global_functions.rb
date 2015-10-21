def dev_or_test?
  Rails.env.development? || Rails.env.test?
end

def ci?
  ENV['CODESHIP'].present?
end