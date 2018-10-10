# frozen_string_literal: true

require 'rubygems'
require 'bundler/setup'
require 'dream_cheeky'
require 'rpi_gpio'
require_relative 'github_controller'
require_relative 'jenkins_controller'

# Class to control interaction with the Dream Cheeky Button & Lightbox
class PeripheralsController
  attr_accessor :last_build_number, :branches_to_merge, :build_in_progress,
                :red_light, :yellow_light, :green_light

  def initialize
    @last_build_number = jenkins.last_build_number
    @branches_to_merge = jenkins.branches_to_merge
    @red_light = nil # Red light gpio
    @yellow_light = nil # Yellow light gpio
    @green_light = nil # Green light gpio
    @current_light = nil # Set to red or green
  end

  def control_lights
    control_working_light
    set_result_status_light
  end

  def run_dream_cheeky # rubocop:disable Metrics/MethodLength
    DreamCheeky::BigRedButton.run do
      open do
        flash_light(current_light)
      end

      close do
        turn_on_light(current_light)
      end

      push do
        merge_it_all!
      end
    end
  end

  private

  def jenkins
    JenkinsController.new
  end

  def github(repo, branch)
    GithubController.new(repo, branch)
  end

  def merge_it_all!
    return false if branches_to_merge['SUCCESS'] == false

    branches_to_merge.each do |repo, branch|
      github(repo, branch).merge_pull_request_and_delete_branch
    end

    # Flash both lights 3 times
  end

  def turn_on_light(light)
    # Turn on the provided light
  end

  def turn_off_light(light)
    # turn off the provided light
  end

  def flash_light(light)
    # Flash the provided light
  end

  def control_working_light
    return flash_light(yellow_light) if jenkins.building?
    turn_off_light(yellow_light)
  end

  def set_result_status_light
    if branches_to_merge[:SUCCESS] == false
      turn_off_light(green_light)
      turn_on_light(red_light)
    else
      turn_off_light(red_light)
      turn_on_light(green_light)
    end
  end
end
