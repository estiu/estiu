def development?
  Rails.env.development?
end

def test?
  Rails.env.test?
end

def dev_or_test?
  development? || test?
end

def production?
  Rails.env.production?
end

def staging?
  Rails.env.staging?
end

def development_or_test?
  dev_or_test?
end

def production_or_staging?
  production? || staging?
end

def ci?
  ENV['CODESHIP'].present?
end