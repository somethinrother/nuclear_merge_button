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
    @current_light = nil
    @closed = true
  end

  def control_lights
    control_working_light
    set_result_status_light
  end

  def run_dream_cheeky # rubocop:disable Metrics/MethodLength
    DreamCheeky::BigRedButton.run do
      open do
        @closed = false
        until closed?
          loop do
            flash_light(light)
          end
        end
      end

      close do
        @closed = true
        gpio.set_high(current_light)
      end

      push do
        merge_it_all!
      end
    end
  end

  private

  def closed?
    @closed
  end

  def jenkins
    JenkinsController.new
  end

  def github(repo, branch)
    GithubController.new(repo, branch)
  end

  def gpio_config
    RPi::GPIO.set_numbering :board
    RPi::GPIO.setup GREEN_LIGHT, as: :output
    RPi::GPIO.setup RED_LIGHT, as: :output
    RPi::GPIO.setup YELLOW_LIGHT, as: :output
  end

  def gpio
    RPi::GPIO
  end

  def merge_it_all!
    return false if branches_to_merge['SUCCESS'] == false

    branches_to_merge.each do |repo, branch|
      github(repo, branch).merge_pull_request_and_delete_branch
    end

    flash_light(GREEN_LIGHT)
    flash_light(GREEN_LIGHT)
  end

  def flash_light(light)
    gpio.set_high(light)
    sleep(1)
    gpio.set_low(light)
    sleep(1)
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
