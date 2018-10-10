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

  def building?
    retrieve_build_details(@last_build_number)['building']
  end

  def compile_data_for_github
    repo_data = if building?
                  repo_data(@second_last_build_number)
                else
                  repo_data(@last_build_number)
                end
    build_tested_repos_hash(repo_data)
  end

  private

  def jenkins
    JenkinsApi::Client.new(
      server_ip: ENV['JENKINS_SERVER_IP'],
      username: ENV['JENKINS_USERNAME'],
      password: ENV['JENKINS_TOKEN']
    )
  end

  def repo_data(build_number)
    retrieve_build_details(build_number)['actions'][0]['parameters']
  end

  def add_repo_to_details_hash(details_hash, repo)
    branch_name = repo['value']
    repo_name = map_jenkins_repo_to_github(repo['name'])
    details_hash[repo_name] = branch_name if custom_branch(repo)
  end

  def build_tested_repos_hash(repo_data)
    unless repo_data.nil?
      repo_details = repo_data.each_with_object({}) do |repo, tested_repos|
        add_repo_to_details_hash(tested_repos, repo)
      end
    end

    return { 'SUCCESS': false } if repo_details.empty? || !repo_details
    repo_details['SUCCESS'] = true
    repo_details
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

  def repo_name_map
    {
      JENKINS_BRANCH: 'jenkins',
      QA_AUTOMATION_BRANCH: 'qa-automation',
      WIKIPOSIT_BRANCH: 'wikiposit',
      NEXT_BRANCH: 'next',
      PERMAHOC_BRANCH: 'permahoc',
      GATEWAY_BRANCH: 'gateway',
      DATAPI_BRANCH: 'DataPI'
    }
  end

  def map_jenkins_repo_to_github(jenkins_branch_name)
    repo_name_map[jenkins_branch_name.to_sym]
  end
end
