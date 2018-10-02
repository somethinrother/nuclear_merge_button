require 'github_api'

class GithubController
  attr_accessor :user, :repo
	
  def initialize(user, repo)
    @user = user
    @repo = repo
    configure
  end
	
  def get_all_branches
	Github::Client::Repos.new.branches.list
  end
  
  def pull_requests
	github.pull_requests.list
  end
	
  def merge_branch
    branch_name = list.body[0].head.ref
    github.pull_requests.merge number: '3'
  end
	
  def delete_branch
    github.git_data.references.delete @user, @repo, 'heads/new_branch'
  end
	
  def configure
    Github.configure do |c|
      c.oauth_token = ENV['GITHUB_ACCESS_TOKEN']
      c.repo = @repo
      c.user = @user
    end
  end
	
  def github
    Github.new
  end
end
