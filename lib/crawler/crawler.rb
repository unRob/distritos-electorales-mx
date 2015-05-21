require 'typhoeus'
require_relative 'errors.rb'
require_relative 'request.rb'
require_relative 'response.rb'
require_relative 'runner.rb'


module Crawler

  VERSION = '2.0'

  @@default_headers = {
    'Accept' => 'text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8',
    'User-Agent' => 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_9_2) AppleWebKit/537.75.14 (KHTML, like Gecko) Version/7.0.3 Safari/537.75.14',
    'X-User-Agent' => "Crawler/#{VERSION} http://representantes.pati.to"
  }
  @@engine = nil
  @@verbose = false
  @@max_concurrency = 100


  def self.engine
    @@engine ||= Typhoeus::Hydra.new(max_concurrency: @@max_concurrency)
  end


  def self.default_headers
    @@default_headers
  end

  def self.default_headers= headers
    @@default_headers = headers
  end


  def self.verbose
    @@verbose
  end

  def self.verbose= bool
    @@verbose = !!bool
  end


  def self.max_concurrency
    @@max_concurrency
  end

  def self.max_concurrency= int
    @@max_concurrency = int.to_i
  end

end