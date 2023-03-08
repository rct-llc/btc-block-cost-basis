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
    blocks = []
    CSV.foreach('./data/blocks/btc.csv') do |row|
      timestamp = row[3].to_i
      blocks.push({
        "height" => row[1].to_i,
        "timestamp" => row[3].to_i,
      }) unless start_date >= Time.at(timestamp)
    end

    first_timestamp, last_timestamp = blocks.map { |block| block["timestamp"] }.minmax
    api_queries = []
    query_api = true
    from = first_timestamp - 500
    to = from + (300_000)
    while query_api
      begin
        format_from = Time.at(from).utc.strftime("%m/%d/%Y %H:%M UTC")
        format_to = Time.at(to).utc.strftime("%m/%d/%Y %H:%M UTC")
        Logger.prompt "Querying Kraken API. From: #{format_from}, to: #{format_to}"
        uri = URI("https://futures.kraken.com/api/charts/v1/spot/pi_xbtusd/1m?from=#{from}&to=#{to}")
        result = Net::HTTP.get(uri)
        json_result = JSON.parse(result)
        api_queries.push(json_result)

        from += 300_000
        future_to = to + 300_000
        now = Time.now.to_i
        to = (future_to < now) ? future_to : now
        sleep 2
        query_api = from <= last_timestamp
      rescue => e
        puts "Error"
        api_queries.size > 0 ? break : return
      end
    end
    # combine api_queries
    all_candles = []
    api_queries.each { |query| all_candles.push(*query["candles"]) }
    all_candles.compact!
    api_queries = nil

    Logger.prompt "Processing retrieved API data. #{all_candles.length} values"

    blocks.each_with_index do |block, index|
      # find the candles index where "time" value is greater than block["timestamp"]
      candle_index = all_candles.index do |candle|
        block_time = block["timestamp"]
        candle_time = candle["time"] / 1000
        block_time >= candle_time && block_time <= candle_time + 60
      end
      candle = all_candles[candle_index]
      block["open"] = candle["open"].to_f.round(2)
      block["high"] = candle["high"].to_f.round(2)
      block["low"] = candle["low"].to_f.round(2)
      block["close"] = candle["close"].to_f.round(2)
    end


    # json
    sorted_blocks = blocks.sort { |a, b| a["height"] <=> b["height"] }
    if File.exist?("#{output_path}/#{exchange_name}.json")
      previous_blocks = JSON.load_file("#{output_path}/#{exchange_name}.json")
      joined_data = previous_blocks += sorted_blocks
      uniq_data = joined_data.uniq { |data| data["height"] }.sort { |a, b| a["height"] <=> b["height"] }
      write_json(uniq_data)
    else
      write_json(sorted_blocks)
    end

    #csv
    format_to_csv = sorted_blocks.map do |block|
      [
        block["height"].to_s,
        block["timestamp"],
        block["open"],
        block["high"],
        block["low"],
        block["close"],
      ]
    end

    if File.exist?("#{output_path}/#{exchange_name}.csv")
      previous_blocks = CSV.read("#{output_path}/#{exchange_name}.csv")[1..-1]
      joined_data = previous_blocks += format_to_csv
      uniq_data = joined_data.uniq { |data| data[0] }.sort { |a, b| a[0] <=> b[0] }
      write_csv(uniq_data)
    else
      write_csv(format_to_csv)
    end

  end

  private

  def write_json(data)
    Logger.prompt "Writing JSON data"
    File.open("#{output_path}/#{exchange_name}.json", "w+") do |file|
      json_data = JSON.pretty_generate(data)
      file.write(json_data)
    end
  end

  def write_csv(data)
    Logger.prompt "Writing CSV data"
    CSV.open(
      "#{output_path}/#{exchange_name}.csv",
      "w+",
      write_headers: true,
      headers: %w(height timestamp open high low close)
    ) do |csv|
      data.each do |block_data|
        csv << block_data
      end
    end
  end

end
