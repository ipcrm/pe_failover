require 'yaml'
conf_file = "/opt/pe_failover/conf/pe_failover.yaml"

if File.exist?(conf_file)
  failover_config = YAML::load_file conf_file

  if failover_config.has_key?('mode')
    Facter.add('pe_failover_mode') do
      setcode do
        failover_config['mode']
      end
    end
  end


  if failover_config.has_key?('key')
    Facter.add('pe_failover_key') do
      setcode do
        failover_config['key']
      end
    end
  end

  if failover_config.has_key?('passive_master')
    Facter.add('pe_failover_passive_master') do
      setcode do
        failover_config['passive_master']
      end
    end
  end
end
