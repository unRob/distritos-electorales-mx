module Crawler
  class Response

    attr_accessor :body, :parser
    attr_reader :code, :original_body, :request

    def initialize response, request
      @request = request
      @code = response.code
      @original_body = response.body
    end

    def body
      if @parser
        data = @parser.call(@original_body)
      else
        data = @original_body
      end
      data
    end

  end
end