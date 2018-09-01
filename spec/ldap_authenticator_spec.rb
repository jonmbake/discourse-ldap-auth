require 'spec_helper'
require 'lib/auth'
require 'ostruct'

def enabled_site_setting(setting=nil)
end

def gem(name, version=nil, opts = {})
end

def auth_provider(opts = {})
end

def register_css(css='')
end

load 'plugin.rb'

describe LDAPAuthenticator do
  before(:all) do
    SiteSetting = OpenStruct.new(ldap_user_create_mode: 'auto')
  end
  before(:each) do
    @user = stub_const('LDAPUser::User', Class.new)
    @auth = LDAPAuthenticator.new
    @entry = OpenStruct.new({
      info: {
        email: 'test@test.org',
        nickname: 'tester',
        name: 'Testy McTesterson'
      }
    })
  end
  context 'when SiteSettings.ldap_user_create_mode is auto' do
    it 'will create auth result with ldap entry data and nil user if user with email does not exist' do
      allow(@user).to receive(:find_by_email).and_return(nil)
      expect(@user).to receive(:find_by_email).with('test@test.org')
      result = @auth.after_authenticate(@entry)
      expect(result.email).to eq(@entry.info[:email])
      expect(result.name).to eq(@entry.info[:name])
      expect(result.username).to eq(@entry.info[:nickname])
      expect(result.failed?).to eq(false)
      expect(result.user).to be_nil
    end
  end

  context 'when SiteSettings.ldap_user_create_mode is none' do
    before(:all) do
      SiteSetting.ldap_user_create_mode = 'none'
    end
    it 'will fail auth if user account does not exist' do
      allow(@user).to receive(:find_by_email).and_return(nil)
      result = @auth.after_authenticate(@entry)
      expect(result.failed?).to eq(true)
      expect(result.failed_reason).to eq('User account does not exist.')
    end
    it 'will pass auth if user account exists' do
      allow(@user).to receive(:find_by_email).and_return(@user)
      result = @auth.after_authenticate(@entry)
      expect(result.failed?).to eq(false)
    end
  end

  context 'when SiteSettings.ldap_user_create_mode is list' do
    before(:each) do
      SiteSetting.ldap_user_create_mode = 'list'
      @group = stub_const('LDAPUser::Group', Class.new)
      allow(@group).to receive(:find_by).with(name: 'staff').and_return('staff_group')
      allow(@group).to receive(:find_by).with(name: 'engineering').and_return('engineering_group')
    end
    it 'will fail auth if list does not contain user with email' do
      allow(@user).to receive(:find_by_email).and_return(nil)
      result = @auth.after_authenticate(@entry)
      expect(result.failed?).to eq(true)
      expect(result.failed_reason).to eq('User with email is not listed in LDAP user list.')
    end
    it 'will pass auth if list contains user with email' do
      #user account exists
      allow(@user).to receive(:find_by_email).and_return(OpenStruct.new(activate: true, groups: []))
      entry = OpenStruct.new({
       info: {
          email: 'example_user@gmail.com',
          nickname: 'ldap_user',
          name: 'LDAP User'
        }
      })
      result = @auth.after_authenticate(entry)
      expect(result.failed?).to eq(false)
    end
    it 'will create user groups when creating new user account' do
      #user account does not exist
      allow(@user).to receive(:find_by_email).and_return(nil)
      allow(@user).to receive(:create!).and_return(OpenStruct.new(activate: true, groups: []))
      entry = OpenStruct.new({
       info: {
          email: 'example_user@gmail.com',
          nickname: 'ldap_user',
          name: 'LDAP User'
        }
      })
      result = @auth.after_authenticate(entry)
      expect(result.failed?).to eq(false)
      expect(result.email).to eq(entry.info[:email])
      #username and name from ldap_user.yml
      expect(result.username).to eq('example_user')
      expect(result.name).to eq('Example User')
      expect(result.user.groups[0]).to eq('staff_group')
      expect(result.user.groups[1]).to eq('engineering_group')
    end
  end

  context 'when SiteSettings.ldap_lookup_users_by is username' do
    before(:all) do
      SiteSetting.ldap_user_create_mode = 'auto'
      SiteSetting.ldap_lookup_users_by = 'username'
    end
    it 'will lookup user by username' do
      expect(@user).to_not receive(:find_by_email)
      expect(@user).to receive(:find_by_username).with('tester')
      @auth.after_authenticate(@entry)
    end
  end
end
