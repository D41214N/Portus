# This file checks for important environment variables. Some of them have to be
# set in order for Portus to work in certain scenarios (e.g. secret key base on
# production), others are strong recommendations.

# Checks that the secret value has been set either in `config/secrets.yml` or as
# an environment variable. If this is not the case, then it raises an exception
# with the proper message.
def mandatory_secret!(env, value)
  return if value.present?
  return if ENV["PORTUS_#{env}"].present?

  raise "Environment variable `PORTUS_#{env}` has not been set! This variable is " \
        "mandatory in production because it's needed for the generation of secrets."
end

if Rails.env.production?
  # Mandatory environment variables for production.
  mandatory_secret!("SECRET_KEY_BASE", Rails.application.secrets.secret_key_base)
  mandatory_secret!("KEY_PATH", Rails.application.secrets.encryption_private_key_path)
  mandatory_secret!("PASSWORD", Rails.application.secrets.portus_password)

  # Strongly recommended environment variables for production.
  if ENV["PORTUS_MACHINE_FQDN_VALUE"].blank?
    if APP_CONFIG["machine_fqdn"]["value"] == APP_CONFIG.default_of("machine_fqdn.value")
      Rails.logger.warn "You have not changed the FQDN configuration. Are you sure about this?"
    end
  end
end
