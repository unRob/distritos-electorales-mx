module Crawler
  class Runner

    attr_accessor :base, :options, :retries, :request_parser, :response_parser

    def initialize base, options={}
      @base = base
      @running = false
      @retries = options[:retries] || 3
    end


    def queue request, &block
      intento = request.to_hydra
      intento.on_complete do |res|
        if res.success?
          response = Response.new(res, request)
          response.parser = @response_parser if @response_parser
          yield request, response
        elsif res.timed_out?
          if request.tries <= @retries
            Crawler.engine.queue execute
          else
            raise Error::Timeout.new request
          end
        else
          raise Error::HTTP.new request, res
        end
      end
      Crawler.engine.queue intento

      start unless running?
    end


    def run requests, &block
      requests.each do |req|
        request = Request.new(base, req)

        begin
          request.instance_eval(&@request_parser) if @request_parser
        rescue Exception => e
          raise Error::Callback.new request, nil, e
        end

        queue request, &block



        # http_request = request.to_hydra
        # http_request.on_complete do |res|
        #   if res.success?
        #     response = Response.new(res, request)
        #     response.parser = @response_parser if @response_parser

        #     yield request, response
        #   elsif res.timed_out?
        #     if request.tries < retries
        #       Crawler.engine.queue request.to_hydra
        #     else
        #       raise Error::Timeout.new request
        #     end
        #   else
        #     puts http_request.to_s
        #     raise Error::HTTP.new request, res
        #   end
        # end
        # Crawler.engine.queue http_request
      end


    end #/run


    def running?
      @running == true
    end

    private
    def start
      Crawler.engine.run
    end


  end
end