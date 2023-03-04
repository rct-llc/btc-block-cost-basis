require_relative 'logger'

require 'csv'
require 'json'
require 'net/http'


class BTCBlocks
  attr_accessor :output_path, :start_date

  def initialize(output_path:, start_date:)
    @output_path = output_path
    @start_date = start_date
  end

  def process
    # Query for BTC blocks in reverse order
    # Get current tip, then work backwards until
    height = current_tip_height
    api_queries = []
    query_api = true

    while query_api
      block_data = blocks(height)
      json_data = JSON.parse(block_data)
      api_queries += json_data
      height = json_data.sort do |a, b|
        b["height"] <=> a["height"]
      end[-1]["height"] - 1
      query_api = api_queries.none? do |data|
        Time.at(data["timestamp"]) < start_date
      end
      sleep 2 # Restrict HTTP requests
    end

    # process the retrieved data
    transformed_data = api_queries.map do |block|
      [block["height"].to_s, block["timestamp"].to_s]
    end.sort { |a, b| a[0] <=> b[0] }
    if File.exist?("#{output_path}/btc.csv")
      previous_blocks = CSV.read("#{output_path}/btc.csv")[1..-1]
      joined_data = previous_blocks += transformed_data
      uniq_data = joined_data.uniq { |data| data[0] }.sort { |a, b| a[0] <=> b[0] }
      write_csv(uniq_data)
    else
      write_csv(transformed_data)
    end

  end

  private

  def current_tip_height
    uri = URI("https://blockstream.info/api/blocks/tip/height")
    height = Net::HTTP.get(uri)
    Logger.prompt "Querying Blockstream Block Tip API - height #{height}"
    sleep 2 # Restrict HTTP requests
    height
  end

  def blocks(height)
    Logger.prompt "Querying Blockstream Block API - height #{height}"
    uri = URI("https://blockstream.info/api/blocks/#{height}")
    Net::HTTP.get(uri)
  end

  def write_csv(data)
    # write to CSV
    Logger.prompt "Writing CSV data"
    CSV.open(
      "#{output_path}/btc.csv",
      'w+',
      write_headers: true,
      headers: ['height', 'timestamp']
    ) do |csv|
      data.each do |block_data|
        csv << block_data
      end
    end
  end

end
