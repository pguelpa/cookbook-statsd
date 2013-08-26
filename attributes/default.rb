default[:statsd][:port] = 8125
default[:statsd][:graphite_port] = 2003
default[:statsd][:graphite_host] = "localhost"
default[:statsd][:config] = {}

default[:statsd][:base_dir] = "/opt/statsd"
default[:statsd][:log_dir] = "/var/log/statsd"
default[:statsd][:conf_dir] = "/etc/statsd"
default[:statsd][:pid_file] = "/var/run/statsd.pid"

default[:statsd][:repo_url] = "https://github.com/etsy/statsd.git"
default[:statsd][:repo_branch] = "master"

default[:statsd][:user] = "statsd"
default[:statsd][:group] = "statsd"
