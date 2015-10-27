# discourse-ldap-auth

A [Discourse](https://github.com/discourse/discourse) plugin to enable LDAP/ActiveDirectory authentication.  Basically just wraps the really great [omniauth-ldap](https://github.com/intridea/omniauth-ldap) gem within a Discourse plugin.

## Setup

I'll defer to this Discourse thread on steps to install a Discourse plugin: [Install a Plugin](https://meta.discourse.org/t/install-a-plugin/19157).  In a nutshell, you just have to edit `app.yml` and add `https://github.com/jonmbake/discourse-ldap-auth ldap` under `hooks > after_code > exec > cmd`.

After the plugin is installed, logging in as an Admin and navigating to `admin/site_settings/category/plugins` will enable you to specify your LDAP settings:

![Settings Page](https://github.com/jonmbake/screenshots/blob/master/discourse-ldap-auth/settings.png)

Once the settings are set (you may need to clear *DISCOURSE_APP/tmp* and restart server), you should have an option to login in with LDAP:

![Login Popup](https://raw.githubusercontent.com/jonmbake/screenshots/master/discourse-ldap-auth/login.png)



