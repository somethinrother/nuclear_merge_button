# frozen_string_literal: true

require 'rubygems'
require 'bundler/setup'
require 'jenkins_api_client'

# Class to control interaction with the Jenkins API
class JenkinsController
  attr_accessor :job, :last_build_number, :second_last_build_number

  def initialize
    @job = ENV['JENKINS_JOB_NAME']
    @last_build_number, @second_last_build_number = retrieve_last_two_builds
  end

  def building?(build_number)
    retrieve_build_details(build_number)['building']
  end

  def retrieve_tested_repo_details(build_number)
    repo_data = retrieve_build_details(build_number)['actions'][0]['parameters']
    unless repo_data.nil?
      repo_details = repo_data.each_with_object({}) do |repo, tested_repos|
        branch_name = repo['value']
        tested_repos[repo['name']] = branch_name if custom_branch(repo)
      end
    end

    return { 'SUCCESS': false } if repo_details.empty? || !repo_details
    repo_details['SUCCESS'] = true
    repo_details
  end

  private

  def jenkins
    JenkinsApi::Client.new(
      server_ip: ENV['JENKINS_SERVER_IP'],
      username: ENV['JENKINS_USERNAME'],
      password: ENV['JENKINS_TOKEN']
    )
  end

  def retrieve_last_two_builds
    builds = jenkins.job.get_builds(@job)
    last_build_number = builds[0]['number'].to_s
    second_last_build_number = builds[1]['number'].to_s
    [last_build_number, second_last_build_number]
  end

  def custom_branch(repo)
    repo_name = repo['name']
    branch_name = repo['value']
    branch_name != 'master' && repo_name != 'REMOTE' && repo_name != 'BROWSERS'
  end

  def retrieve_build_details(build_number)
    jenkins.job.get_build_details(@job, build_number)
  end
end
