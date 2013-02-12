require 'json'
require 'pp'
require 'uri'
require 'net/https'

desc 'Github migration script'
namespace :redmine do
namespace :plugins do
task :migrate_from_github => :environment do
  module GithubMigrate
    GITHUB_API = 'https://api.github.com'
    class GithubIssue
      def self.all(params)
        url = "#{GITHUB_API}/repos/#{params[:owner]}/#{params[:repo]}/issues"
        puts url
        send_req url
      end
      def self.send_req(url)
        uri = URI(url)
        pp uri.inspect
        https = Net::HTTP.new(uri.host, uri.port)
        https.use_ssl = true
        https.ca_file = '/etc/pki/tls/cert.pem'
        https.verify_mode = OpenSSL::SSL::VERIFY_PEER
        https.verify_depth = 5
        body = ""
        https.start { |w|
          response = w.get(uri.path)
          body = response.body
        }
        hash = JSON.parse(body)
        pp hash
      end
    end
    def self.migrate(params)
      puts "migrate..."
      puts GITHUB_API
      puts params
      GithubIssue.all(params)
    end
  end
  github_params = {
    :owner => 'tamu222i',
    :repo => 'redmine_migrate_from_github',
  }
  GithubMigrate.migrate github_params
end
end
end
