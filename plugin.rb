# name:ldap 
# about: A plugin to provide ldap authentication. 
# version: 0.1.0
# authors: Jon Bake <jonmbake@gmail.com>

enabled_site_setting :ldap_enabled
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
        strategy_opts = env["omniauth.strategy"].options
        strategy_opts[:host] = SiteSetting.ldap_hostname
        strategy_opts[:port] = SiteSetting.ldap_port
        strategy_opts[:method] = SiteSetting.ldap_method
        strategy_opts[:base] = SiteSetting.ldap_base
        strategy_opts[:uid] = SiteSetting.ldap_uid
        strategy_opts[:name_proc] = Proc.new {|name| name.gsub(/@.*$/,'')}
        strategy_opts[:bind_dn] = SiteSetting.ldap_bind_db
        strategy_opts[:password] = SiteSetting.ldap_password
      }
  end
end

class LDAPStrategy < OmniAuth::Strategies::LDAP
  option :name, 'ldap'
  option :name_proc, lambda {|n| n.split('@')[0] }
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
