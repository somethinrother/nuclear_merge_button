# frozen_string_literal: true

require 'rubygems'
require 'bundler/setup'
require 'jenkins_api_client'

# Class to control interaction with the Jenkins API
class JenkinsController
  attr_accessor

  def initialize(user, repo); end
end
