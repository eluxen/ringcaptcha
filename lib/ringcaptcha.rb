require "ringcaptcha/version"
require 'json'
require 'ostruct'

#
# Ringcaptcha API Integration
#
# see https://bitbucket.org/ringcaptcha/ringcaptcha-docs/src/437ce808904ad6879c31399cfb8e3c8aee9d91d0/api/

module Ringcaptcha

  # returns {status: "SUCCESS",phone: "+XXXXXXXXX",country: "XX",area: "XX",block: "XXXX",subscriber: "XXXX"}
  def self.normalize(phone)
    check_keys!
    return api('normalize', phone:phone)
  end

  def self.app_key=(_app_key)
    @app_key = _app_key
  end

  def self.api_key=(_api_key)
    @api_key = _api_key
  end

  def self.secret_key=(_secret_key)
    @secret_key = _secret_key
  end

  def self.check_keys!
    raise "please set Ringcaptcha.api_key and Ringcaptcha.app_key" if @app_key.blank? || @api_key.blank?
  end

  class Response < OpenStruct
    def error?
      self.status == "ERROR"
    end

    def success?
      self.status == "SUCCESS"
    end
  end

  private

  def self.api(path, params = {})
    uri = URI.parse("https://api.ringcaptcha.com")
    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = true
    http.verify_mode = OpenSSL::SSL::VERIFY_NONE
    request = Net::HTTP::Post.new("/#{@app_key}/#{path}")
    request.add_field('Content-Type', 'application/x-www-url-encoded')
    request.set_form_data params.merge!(api_key:@api_key)

    response = http.request(request)
    json = JSON.parse(response.body)
    return Response.new(json.symbolize_keys!)
  end

end