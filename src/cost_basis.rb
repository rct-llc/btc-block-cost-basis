require_relative 'logger'

require 'csv'
require 'json'
require 'net/http'

class CostBasis
  attr_accessor :exchange_name, :output_path, :start_date

  def initialize(exchange_name:, output_path:, start_date:)
    @exchange_name = exchange_name
    @output_path = output_path
    @start_date = start_date
  end

  def process

  end


end
