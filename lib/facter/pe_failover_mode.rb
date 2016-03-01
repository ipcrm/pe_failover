conf_file = "/opt/pe_failover/conf/pe_failover.conf"

if File.exist?(conf_file)
  f = File.open("/opt/pe_failover/conf/pe_failover.conf", "r")
  failover_mode = f.read.chomp.split('=')[1]
  f.close

  Facter.add('pe_failover_mode') do
    setcode do
      failover_mode
    end
  end
end




