# name:ldap 
# about: A plugin to provide ldap authentication. 
# version: 0.1.0
# authors: Jon Bake <jonmbake@gmail.com>

enabled_site_setting :ldap_enabled

gem 'pyu-ruby-sasl', '0.0.3.3', require: false
gem 'rubyntlm', '0.1.1', require: false
gem 'net-ldap', '0.3.1'
gem 'omniauth-ldap', '1.0.4'

class LDAPAuthenticator < ::Auth::Authenticator
  def name
    'ldap'
  end

  def after_authenticate(auth_options)
    info = auth_options.info
    result = Auth::Result.new
    email = result.email = info[:email]
    result.name = info[:name]
    result.user = User.find_by_email(email)
    result.omit_username = true
    result.email_valid = true
    result
  end

  def register_middleware(omniauth)
    omniauth.provider :ldap,
      setup:  -> (env) {
        env["omniauth.strategy"].options.merge!(
          host: SiteSetting.ldap_hostname,
          port: SiteSetting.ldap_port,
          method: SiteSetting.ldap_method,
          base: SiteSetting.ldap_base,
          uid: SiteSetting.ldap_uid,
          bind_dn: SiteSetting.ldap_bind_db,
          password: SiteSetting.ldap_password
        )
      }
  end
end

auth_provider title: 'Login with LDAP',
  message: 'Log in with your LDAP credentials',
  frame_width: 920,
  frame_height: 800,
  authenticator: LDAPAuthenticator.new

register_css <<CSS
  .btn.ldap {
    background-color: #517693;
  }
CSS
