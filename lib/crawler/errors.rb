module Crawler
  module Error


    class HTTP < ::StandardError
      attr_accessor :request, :response

      def initialize request, response=nil
        @response = response if response

        @request = request
      end


      def to_s
        "HTTP #{response.code}"
      end
    end


    class Timeout < HTTP
      def initialize request, response
        super request
      end

      def to_s
        "Timeout after #{request.connect_time}"
      end
    end


    class Callback < ::StandardError
      attr_accessor :exception, :response, :request

      def initialize request, exeption
        super exception
        @request = request
      end
    end

  end
end