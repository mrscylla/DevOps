set RAILS_ENV=production
d:
cd \_WWW\redmine
rake redmine:plugins:ldap_sync:sync_users > D:\Users\MAV\GIT\devops\cmd\ldap_sync.log