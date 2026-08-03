Rails.application.config.middleware.use OmniAuth::Builder do
  provider :keycloak_openid,
           ENV.fetch('KEYCLOAK_CLIENT_ID', ''),
           ENV.fetch('KEYCLOAK_CLIENT_SECRET', ''),
           client_options: {
             site: 'https://sso-dev.odd.works',
             realm: 'odt',
             base_url: ''
           },
           name: 'keycloak'
end

# Rails.application.config.middleware.use OmniAuth::Builder do
#   provider :keycloak_openid,
#            ENV.fetch('KEYCLOAK_CLIENT_ID'),
#            ENV.fetch('KEYCLOAK_CLIENT_SECRET'),
#            client_options: {
#              site: 'https://sso-dev.odd.works',
#              realm: 'odt'
#            },
#            name: 'keycloak'
# end