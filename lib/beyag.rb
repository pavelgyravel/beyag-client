require "beyag/version"
require "active_support"
require "faraday"
require "faraday_middleware"

module Beyag
  autoload :Client, "beyag/client"
  autoload :Response, "beyag/response"
end
