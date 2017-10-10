set RAILS_ENV=production
d:
cd \_WWW\redmine
rake redmine:plugins:email_fetcher:fetch_all_emails RAILS_ENV=production