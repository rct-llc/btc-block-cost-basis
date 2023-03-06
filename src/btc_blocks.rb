require_relative 'logger'

require 'csv'
require 'json'
require 'net/http'

class BTCBlocks
  API_HOST = ENV["CI"] ? "https://blockstream.info" : "http://localhost:3003"
  attr_accessor :output_path, :start_date

  def initialize(output_path:, start_date:)
    @output_path = output_path
    @start_date = start_date
  end

  def process
    # query for btc blocks in reverse order
    # get current tip, then work backwards until start_date
    height = current_tip_height
    api_queries = []
    previous_block_heights = {}
    query_api = true

    if File.exist?("#{output_path}/btc.csv")
      CSV.foreach("#{output_path}/btc.csv") do |row|
        previous_block_heights[row[1].to_i] = row[3].to_i
      end
    end

    while query_api
      if previous_block_heights.keys.include?(height)
        break if Time.at(previous_block_heights[height]) < start_date
        height -= 1
        next
      end
      begin
        block_data = blocks(height)
        json_data = JSON.parse(block_data)
        json_data = standardize_json_data(json_data) if API_HOST == 'http://localhost:3003'
        api_queries += json_data
        if json_data.size > 1
          height = json_data.sort do |a, b|
            b["height"] <=> a["height"]
          end[-1]["height"] - 1
        else
          height = json_data[0]["height"] - 1
        end
        query_api = api_queries.none? do |data|
          Time.at(data["timestamp"]) < start_date
        end
        restrict_http_request
      rescue => e
        # save the data that was collected
        # remove the last item
        api_queries.pop
        puts "Error at block #{height}"
        break
      end
    end

    # process and store the retrieved data
    # json
    sorted_data = api_queries.sort { |a, b| a["height"] <=> b["height"] }.each do |block|
      block["bits"] = block["bits"].to_i(16) unless block["bits"].is_a?(Integer)
    end
    if File.exist?("#{output_path}/btc.json")
      previous_blocks = JSON.load_file("#{output_path}/btc.json")
      joined_data = previous_blocks += sorted_data
      uniq_data = joined_data.uniq { |data| data["height"] }.sort { |a, b| a["height"] <=> b["height"] }
      write_json(uniq_data)
    else
      write_json(sorted_data)
    end
    # csv
    format_to_csv = sorted_data.map do |block|
      [
        block["id"],
        block["height"].to_s,
        block["version"].to_s,
        block["timestamp"].to_s,
        block["tx_count"].to_s,
        block["size"].to_s,
        block["weight"].to_s,
        block["merkle_root"],
        block["previousblockhash"],
        block["mediantime"].to_s,
        block["nonce"].to_s,
        block["bits"].to_s,
        block["difficulty"]
      ]
    end
    if File.exist?("#{output_path}/btc.csv")
      previous_blocks = CSV.read("#{output_path}/btc.csv")[1..-1]
      joined_data = previous_blocks += format_to_csv
      uniq_data = joined_data.uniq { |data| data[1] }.sort { |a, b| a[1] <=> b[1] }
      write_csv(uniq_data)
    else
      write_csv(format_to_csv)
    end
  end

  private

  def current_tip_height
    uri = URI("#{API_HOST}/api/blocks/tip/height")
    height = Net::HTTP.get(uri)
    Logger.prompt "Querying API Block Tip - height #{height}"
    restrict_http_request
    height
  end

  def blocks(height)
    Logger.prompt "Querying API Block - height #{height}"
    block_path = API_HOST == 'http://localhost:3003' ? 'block' : 'blocks'
    uri = URI("#{API_HOST}/api/#{block_path}/#{height}")
    Net::HTTP.get(uri)
  end

  def write_csv(data)
    Logger.prompt "Writing CSV data"
    CSV.open(
      "#{output_path}/btc.csv",
      'w+',
      write_headers: true,
      headers: %w(id height version timestamp tx_count size weight
        merkle_root previousblockhash mediantime nonce bits difficulty)
    ) do |csv|
      data.each do |block_data|
        csv << block_data
      end
    end
  end

  def write_json(data)
    Logger.prompt "Writing JSON data"
    File.open("#{output_path}/btc.json", 'w+') do |file|
      json_data = JSON.pretty_generate(data)
      file.write(json_data)
    end
  end

  def restrict_http_request
    sleep 2 unless API_HOST == 'http://localhost:3003'
  end

  def standardize_json_data(data)
    [{
      "id" => data["hash"],
      "height" => data["height"],
      "version" => data["version"],
      "timestamp" => data["time"],
      "tx_count" => data["nTx"],
      "size" => data["size"],
      "weight" => data["weight"],
      "merkle_root" => data["merkleroot"],
      "previousblockhash" => data["previousblockhash"],
      "mediantime" => data["mediantime"],
      "nonce" => data["nonce"],
      "bits" => data["bits"],
      "difficulty" => data["difficulty"],
    }]
  end

end
