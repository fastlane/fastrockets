require 'json'
require 'net/http'
require 'pty'
require 'pry'

require './launcher'

SERVER_URL = "https://refresher.fastlane.tools/"

# command = "./minimal-example"
command = "ls"

last_result = nil

launcher = FastRockets::Launcher.new

PTY.spawn(command) do |stdout, stdin, pid|
  loop do
    launches = JSON.parse(Net::HTTP.get(URI.parse(SERVER_URL)))
    if last_result
      diff = {}
      launches.each { |k, v| diff[k] = v - last_result[k] if v != last_result[k] }
      
      diff.each do |tool_name, launches|
        while launches > 0
          value = launcher.fire!(tool_name)
          puts value
          launches -= 1
        end
      end
    end
    last_result = launches
    last_result['deliver'] -= 1
    sleep 1.0

    puts "-1"
  end
end