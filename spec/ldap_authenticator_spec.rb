# frozen_string_literal: true
require 'rails_helper'

describe LDAPAuthenticator do

  let(:authenticator) { LDAPAuthenticator.new }
  let(:auth_hash) { OmniAuth::AuthHash.new(
    info: {
      email: 'test@test.org',
      nickname: 'tester',
      name: 'Testy McTesterson'
    }
  )}

  context 'when SiteSettings.ldap_user_create_mode is auto' do
    it 'will create auth result with ldap entry data and nil user if user with email does not exist' do
      result = authenticator.after_authenticate(auth_hash)
      expect(result.email).to eq(auth_hash.info[:email])
      expect(result.name).to eq(auth_hash.info[:name])
      expect(result.username).to eq(auth_hash.info[:nickname])
      expect(result.failed?).to eq(false)
      expect(result.user).to be_nil
    end
  end

  context 'when SiteSettings.ldap_user_create_mode is none' do
    before do
      SiteSetting.ldap_user_create_mode = 'none'
    end
    it 'will fail auth if user account does not exist' do
      result = authenticator.after_authenticate(auth_hash)
      expect(result.failed?).to eq(true)
      expect(result.failed_reason).to eq('User account does not exist.')
    end
    it 'will pass auth if user account exists' do
      user = Fabricate(:user, email: auth_hash.info[:email])
      result = authenticator.after_authenticate(auth_hash)
      expect(result.failed?).to eq(false)
      expect(result.user).to eq(user)
    end
  end

  context 'when SiteSettings.ldap_user_create_mode is list' do
    before do
      SiteSetting.ldap_user_create_mode = 'list'
      Fabricate(:group, name: 'team')
      Fabricate(:group, name: 'engineering')
    end
    it 'will fail auth if list does not contain user with email' do
      result = authenticator.after_authenticate(auth_hash)
      expect(result.failed?).to eq(true)
      expect(result.failed_reason).to eq('User with email is not listed in LDAP user list.')
    end
    it 'will pass auth if list contains user with email' do
      #user account exists
      Fabricate(:user, email: 'example_user@gmail.com')
      entry = OmniAuth::AuthHash.new({
       info: {
          email: 'example_user@gmail.com',
          nickname: 'ldap_user',
          name: 'LDAP User'
        }
      })
      result = authenticator.after_authenticate(entry)
      expect(result.failed?).to eq(false)
    end
    it 'will create user groups when creating new user account' do
      #user account does not exist
      entry = OmniAuth::AuthHash.new({
       info: {
          email: 'example_user@gmail.com',
          nickname: 'ldap_user',
          name: 'LDAP User'
        }
      })
      result = authenticator.after_authenticate(entry)
      expect(result.failed?).to eq(false)
      expect(result.email).to eq(entry.info[:email])
      #username and name from ldap_user.yml
      expect(result.username).to eq('example_user')
      expect(result.name).to eq('Example User')
      expect(result.user.groups[0].name).to eq('team')
      expect(result.user.groups[1].name).to eq('engineering')
    end
  end

  context 'when SiteSettings.ldap_lookup_users_by is username' do
    before do
      SiteSetting.ldap_user_create_mode = 'auto'
      SiteSetting.ldap_lookup_users_by = 'username'
    end
    it 'will lookup user by username' do
      user = Fabricate(:user, username: "tester")
      result = authenticator.after_authenticate(auth_hash)
      expect(result.user).to eq(user)
    end
  end

  describe "overrides_username behaviour" do
    it "overrides username during initial signup" do
      result = authenticator.after_authenticate(auth_hash)
      expect(result.username).to eq(auth_hash.info[:nickname])
      expect(result.failed?).to eq(false)
      expect(result.user).to be_nil
      expect(result.overrides_username).to eq(true)
    end

    it "does not override username on future logins" do
      SiteSetting.ldap_lookup_users_by = 'username'
      user = Fabricate(:user, username: "tester")
      result = authenticator.after_authenticate(auth_hash)
      expect(result.username).to eq(auth_hash.info[:nickname])
      expect(result.failed?).to eq(false)
      expect(result.user).to eq(user)
      expect(result.overrides_username).to eq(nil)
    end
  end
end
