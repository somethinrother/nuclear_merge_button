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
    @last_build_result = jenkins.retrieve_result(last_build_number)
    @branches_to_merge = jenkins.retrieve_tested_repo_details(last_build_number)
    @build_in_progress = jenkins.building?(last_build_number)
  end

  def jenkins
    JenkinsController.new
  end

  def open_lid
    # Flash red light if last build was failed
  end

  def close_lid
    # if red light is flashing, set it to solid
  end

  def push_button
    # Do nothing if last build was a failure
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

  def self.refresh
    # this is a cron job that will run periodically to reset the current values
    # of this model. This will serve to set the working light, set the results
    # light, and reset the branches to merge, if the run is successful
  end
end
