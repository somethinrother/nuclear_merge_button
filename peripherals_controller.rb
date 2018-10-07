# frozen_string_literal: true

require 'rubygems'
require 'bundler/setup'
require 'dream_cheeky'
require_relative 'github_controller'
require_relative 'jenkins_controller'

# Class to control interaction with the Dream Cheeky Button & Lightbox
class PeripheralsController
  attr_accessor :last_build_result

  def initialize
    last_build_number = jenkins.last_build_number
    @branches_to_merge = jenkins.retrieve_tested_repo_details(last_build_number)
    @build_in_progress = jenkins.building?(last_build_number)
  end

  def open_lid
    # Flash red light if last build was failed
  end

  def close_lid
    # if red light is flashing, set it to solid
  end

  def push_button
    return false if @branches_to_merge['SUCCESS'] == false
    # If last build was a success, instantiate a GithubController for each
    # entry in @branches_to_merge, and call merge_pull_request
  end

  def set_working_light
    # Blinks a yellow light if the current build is in progress. If this is
    # running, reset the value of last build number to -1
  end

  def set_result_status_light
    # Checks the status of the last build number, and turns on a red or green
    # light appropriately
  end

  def refresh
    last_build_number = jenkins.last_build_number
    @branches_to_merge = jenkins.retrieve_tested_repo_details(last_build_number)
    @build_in_progress = jenkins.building?(last_build_number)
  end

  private

  def jenkins
    JenkinsController.new
  end
end
