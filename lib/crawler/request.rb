module Crawler
  class Request

    URL_DELIMITER = /(\{\{[^}]+\}\})/
    URL_DELIMITER_CHARS = /[{}]+/

    attr_accessor :url, :data, :headers, :body, :method, :http
    attr_reader :tries


    def initialize url, data=[]
      @url = url
      @data = data
      @tries = 0
      @headers = {}
      @method = :get
    end


    def url
      str = @url
      if data.is_a? Hash
        str = @url.gsub(URL_DELIMITER) {|match|
          key = match.gsub(URL_DELIMITER_CHARS, '')
          data[key.to_sym]
        }
      end
      return str
    end


    def options
      {
        headers: Crawler.default_headers.merge(headers),
        body: body,
        method: method,
        verbose: Crawler.verbose,
        accept_encoding: "gzip"
      }
    end


    def to_hydra
      @tries += 1
      Typhoeus::Request.new(url, options)
    end


    def retry
      if tries < 3
        Crawler.engine.queue execute
      else
        raise Error::Timeout.new request
      end
    end


  end
end