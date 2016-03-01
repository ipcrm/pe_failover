require 'yaml'
conf_file = "/opt/pe_failover/conf/pe_failover.yaml"

if File.exist?(conf_file)
  failover_config = YAML::load_file conf_file

  if failover_config.has_key?('pe_failover_mode')
    Facter.add('pe_failover_mode') do
      setcode do
        failover_config['pe_failover_mode']
      end
    end
  end


  if failover_config.has_key?('pe_failover_key')
    Facter.add('pe_failover_key') do
      setcode do
        failover_config['pe_failover_key']
      end
    end
  end
end
