# name:ldap 
# about: A plugin to provide ldap authentication. 
# version: 0.2.0
# authors: Jon Bake <jonmbake@gmail.com>

enabled_site_setting :ldap_enabled

gem 'pyu-ruby-sasl', '0.0.3.3', require: false
gem 'rubyntlm', '0.3.4', require: false
gem 'net-ldap', '0.14.0'
gem 'omniauth-ldap', '1.0.5'

require 'yaml'
require_relative 'lib/ldap_user'

class LDAPAuthenticator < ::Auth::Authenticator
  def name
    'ldap'
  end

  def after_authenticate(auth_options)
    return auth_result(auth_options.info)
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
          password: SiteSetting.ldap_password,
          filter: SiteSetting.ldap_filter
        )
      }
  end

  private
  def auth_result(auth_info)
    case SiteSetting.ldap_user_create_mode
      when 'none'
        ldap_user = LDAPUser.new(auth_info)
        return ldap_user.account_exists? ? ldap_user.auth_result : fail_auth('User account does not exist.')
      when 'list'
        user_descriptions = load_user_descriptions
        return fail_auth('List of users must be provided when ldap_user_create_mode setting is set to \'list\'.') if user_descriptions.nil?
        #match on email
        match = user_descriptions.find { |ud|  auth_info[:email].casecmp(ud[:email]) == 0 }
        return fail_auth('User with email is not listed in LDAP user list.') if match.nil?
        match[:nickname] = match[:username] || auth_info[:nickname]
        match[:name] = match[:name] || auth_info[:name]
        return LDAPUser.new(match).auth_result
      when 'auto'
        return LDAPUser.new(auth_info).auth_result
      else
        return fail_auth('Invalid option for ldap_user_create_mode setting.')
    end
  end
  def fail_auth(reason)
    result = Auth::Result.new
    result.failed = true
    result.failed_reason = reason
    result
  end
  def load_user_descriptions
    file_path = "#{File.expand_path(File.dirname(__FILE__))}/ldap_users.yml"
    return nil unless File.exists?(file_path)
    return YAML.load_file(file_path)
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
