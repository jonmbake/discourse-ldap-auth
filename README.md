[![CI](https://github.com/jonmbake/discourse-ldap-auth/workflows/CI/badge.svg)](https://github.com/jonmbake/discourse-ldap-auth/actions?query=workflow%3ACI)
[![CodeQL Scan](codeql-scan.svg)](https://github.com/jonmbake/discourse-ldap-auth/security/code-scanning?query=tool%3ACodeQL)

# discourse-ldap-auth

A [Discourse](https://github.com/discourse/discourse) plugin to enable LDAP/ActiveDirectory authentication.

![Login Popup](https://raw.githubusercontent.com/jonmbake/screenshots/master/discourse-ldap-auth/login.png)

## Setup

Checkout: [Installing a Plugin](https://meta.discourse.org/t/install-a-plugin/19157).

## Configuration

After the plugin is installed, logging in as an Admin and navigating to `admin/site_settings/category/plugins` will enable you to specify your LDAP settings.  Most of the configuration options are documented in [omniauth-ldap](https://github.com/intridea/omniauth-ldap).

![Settings Page](https://github.com/jonmbake/screenshots/blob/master/discourse-ldap-auth/settings.png)

## A Note on User Account Creation

By default, user accounts are automatically created (if they don't already exist) after authentication using *name*, *nickname* and *email* attributes of the LDAP entry.  If you do not want this behavior, you can change the *ldap_user_create_mode* configuration value to one of the following:

  Name | Description
-------| --------------
auto   | Automatically create a Discourse Account after authenticating through LDAP if account does not exist (default).
list   | Provide a list of users in *ldap_users.yml*.  Will only create an account and pass authentication if user with email is in list. See example [ldap_user.yml](ldap_users.yml).
none   | Fail auth if the user account does not already exist.  This is a good option for an Admin that creates accounts ahead of time.

*list* also allows the specifying of *User Groups*, which will be automatically assigned to the user on creation.  It also allows specifying a different *username* (for local account) and *name* for the Discourse User Account than what is returned in the LDAP entry.

## Yet Another Note on the _Attribute to lookup users by_ Setting

The _Lookup Users By Attribute_ setting specifies how to to link the LDAP response entry to a user within _Discourse_. By
default, it uses the _email_ attribute in the LDAP entry to try and find an existing Discourse user. If email address is
unlikely to change for a given user, it is a good idea to keep this default setting.

If, on the other hand, LDAP email address has the possibility of changing, setting _Attribute to lookup users by_ to _username_ is the way to go to avoid "de-linking"
the Discourse User from its corresponding LDAP entry.

The only possible values are _email_ or _username_.

## Other Tips

When disabling Local Login and other authentication services, clicking the `Login` or `Sign Up` button will directly bring up the LDAP Login popup.

![Disable Local](https://github.com/jonmbake/screenshots/blob/master/discourse-ldap-auth/disable_local.png)

![LDAP Login Popup](https://github.com/jonmbake/screenshots/blob/master/discourse-ldap-auth/ldap_popup.png)

## Submitting a PR

Make sure coding style is maintained and all tests pass by running:

```
rspec
```

## Version History

[0.6.0](https://github.com/jonmbake/discourse-ldap-auth/tree/v0.6.0)- Update omit_username to override_username following Discourse core changes

[0.5.0](https://github.com/jonmbake/discourse-ldap-auth/tree/v0.5.0)- Remove call to deprecated Discourse code from [FEATURE: Use full page redirection for all external auth methods](https://github.com/discourse/discourse/pull/8092)

[0.4.1](https://github.com/jonmbake/discourse-ldap-auth/tree/v0.4.1)- Make LDAP Password field secret

[0.4.0](https://github.com/jonmbake/discourse-ldap-auth/tree/v0.4.0)- Fix Undefined variable: "$fa-var-sitemap" error when upgrading to Discourse version > 2.2.0

[0.3.8](https://github.com/jonmbake/discourse-ldap-auth/tree/v0.3.8)- Fix `enabled?` undefined warning

[0.3.7](https://github.com/jonmbake/discourse-ldap-auth/tree/v0.3.7)- Add _Attribute to lookup users by_ Setting

[0.3.6](https://github.com/jonmbake/discourse-ldap-auth/tree/v0.3.6)- Fixed bug where user who changed email can no longer be looked up

[0.3.5](https://github.com/jonmbake/discourse-ldap-auth/tree/v0.3.5)- Updated styling of LDAP login popup

[0.3.0](https://github.com/jonmbake/discourse-ldap-auth/tree/v0.3.0)- Fixed typo to `ldap_bind_db` configuration name

[0.2.0](https://github.com/jonmbake/discourse-ldap-auth/tree/v0.2.0) - Added ldap_user_create_mode configuration option.

[0.1.0](https://github.com/jonmbake/discourse-ldap-auth/tree/v0.1.0) - Init

**Note on Updating to Version 0.3** A typo was fixed in the name of a configuration. `ldap_bind_db` was renamed to `ldap_bind_dn`. If you update from <0.2 to 0.3, you will have to reset the `ldap_bind_dn` configuration value. There is a fallback to use the old configuration value, but this will be removed in a future release.

## License

MIT
