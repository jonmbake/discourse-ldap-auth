# discourse-ldap-auth

A [Discourse](https://github.com/discourse/discourse) plugin to enable LDAP/ActiveDirectory authentication.  Basically just wraps the [omniauth-ldap](https://github.com/intridea/omniauth-ldap) gem within a Discourse plugin.

## Setup

I'll defer to this great guide on installing Discourse plugins, written by the Discourse folks themselves: [Install a Plugin](https://meta.discourse.org/t/install-a-plugin/19157).

After the plugin is installed, logging in as an Admin and navigating to `admin/site_settings/category/plugins` will enable you to specify your LDAP settings:

![Settings Page](https://github.com/jonmbake/screenshots/blob/master/discourse-ldap-auth/settings.png)

Once the settings are set (you may need to clear *DISCOURSE_APP/tmp* and restart server), you should have an option to login in with LDAP:

![Login Popup](https://raw.githubusercontent.com/jonmbake/screenshots/master/discourse-ldap-auth/login.png)



