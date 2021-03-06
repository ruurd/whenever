# Environment defaults to production
set :environment, "production"
# Path defaults to the directory `whenever` was run from
set :path, Whenever.path

# All jobs are wrapped in this template.
# http://blog.scoutapp.com/articles/2010/09/07/rvm-and-cron-in-production

shell = "/bash"
ENV['PATH'].split(':').each do |folder| 
    if File.exists?(folder + shell) && File.executable?(folder + shell)
        shell = folder + shell
        break
    end
end

set :job_template, shell + " -l -c ':job'"

job_type :command, ":task :output"

# Run rake through bundler if possible
if Whenever.bundler?
  job_type :rake, "cd :path && RAILS_ENV=:environment bundle exec rake :task --silent :output"
  job_type :script, "cd :path && RAILS_ENV=:environment bundle exec script/:task :output"
else
  job_type :rake, "cd :path && RAILS_ENV=:environment rake :task --silent :output"
  job_type :script, "cd :path && RAILS_ENV=:environment script/:task :output"
end

# Create a runner job that's appropriate for the Rails version,
if Whenever.rails3?
  job_type :runner, "cd :path && script/rails runner -e :environment ':task' :output"
else
  job_type :runner, "cd :path && script/runner -e :environment ':task' :output"
end
