# frozen_string_literal: true

require 'rubygems'
require 'bundler/setup'
require 'github_api'

# Class to control interaction with the Github API
class GithubController
  attr_accessor :user, :repo, :branch

  def initialize(user, repo, branch)
    @user = user
    @repo = repo
    @branch = branch
    configure
  end

  def merge_pull_request
    pull_requests.each do |request|
      if request.head.ref == @branch
        merge_branch(request.number)
        delete_branch
      end
    end
  end

  def merge_branch(pull_request_number_string)
    github.pull_requests.merge(number: pull_request_number_string)
  end

  def delete_branch
    github.git_data.references.delete(@user, @repo, "heads/#{@branch}")
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

  def pull_requests
    github.pull_requests.list
  end
end
