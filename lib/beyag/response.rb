require "ostruct"

module Beyag
  class Response
    attr_reader :response, :data

    def initialize(response)
      @response = response
      @data = begin
                JSON.parse(response.body)
              rescue JSON::ParserError
                {}
              end
    end

    def id
      transaction["id"]
    end

    def service_no
      transaction["erip"]["service_no"]
    end

    def transaction
      data["transaction"]
    end

    def successful?
      (200..299).include?(status)
    end

    def error?
      errors.present?
    end

    def message
      data["message"] || transaction["message"]
    end

    def errors
      data["errors"]
    end

    def status
      response.status.to_i
    end
  end
end
