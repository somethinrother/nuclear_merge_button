# frozen_string_literal: true

require 'rubygems'
require 'bundler/setup'
require 'github_api'

# Class to control interaction with the Github API
class GithubController
  attr_accessor :user, :repo

  def initialize(user, repo)
    @user = user
    @repo = repo
    configure
  end

  def retrieve_all_branches
    Github::Client::Repos.new.branches.list
  end

  def pull_requests
    github.pull_requests.list
  end

  def merge_branch
    github.pull_requests.merge number: '6'
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
