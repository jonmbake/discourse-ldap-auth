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

## Other Tips

When disabling Local Login and other authentication services, clicking the `Login` button or `Sign Up` will directly bring up LDAP Login popup.

![Disable Local](https://github.com/jonmbake/screenshots/blob/master/discourse-ldap-auth/disable_local.png)

![LDAP Login Popup](https://github.com/jonmbake/screenshots/blob/master/discourse-ldap-auth/ldap_popup.png)

## Version History

[0.2.0](https://github.com/jonmbake/discourse-ldap-auth) - Added ldap_user_create_mode configuration option.

[0.1.0](https://github.com/jonmbake/discourse-ldap-auth/tree/v0.1.0) - Init
