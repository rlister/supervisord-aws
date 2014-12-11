require 'aws-sdk-core'
require 'xmlrpc/client'
require 'sinatra'
require 'net/http'
require 'json'

## set the following environment variables:
##   AWS_ACCESS_KEY_ID
##   AWS_SECRET_ACCESS_KEY
##   REGIONS (e.g. 'us-east-1 us-west-2')
##   SUPERVISORD_PORT
##   SUPERVISORD_USER
##   SUPERVISORD_PASSWORD
##   CADVISOR_PORT (default: 8080)

REGIONS = ENV['REGIONS'].split(/\s+/)

def autoscaling(region)
  Aws::AutoScaling::Client.new(region: region)
end

def ec2(region)
  Aws::EC2::Client.new(region: region)
end

def supervisord_procs(ip)
  XMLRPC::Client.new3(
    host:     ip,
    port:     ENV['SUPERVISORD_PORT'],
    user:     ENV['SUPERVISORD_USER'],
    password: ENV['SUPERVISORD_PASSWORD']
  ).call('supervisor.getAllProcessInfo')
rescue => e
  logger.warn "#{ip} supervisord: #{e.message}"
  []
end

def cadvisor_containers(ip)
  port = ENV.fetch('CADVISOR_PORT', 8080)
  http = Net::HTTP.new(ip, port)
  http.read_timeout = 5
  JSON.parse(http.get('/api/v1.2/docker/').body).map do |_, v|
    v.fetch('aliases', [])
  end
rescue => e
  logger.warn "#{ip} cadvisor: #{e.message}"
  [ ]
end

get '/' do
  @groups = Hash.new { |h,k| h[k] = [] }

  REGIONS.map do |region|
    autoscaling(region).describe_auto_scaling_groups.auto_scaling_groups.map do |group|
      @groups[group.auto_scaling_group_name].push("#{region} (#{group.instances.count})")
    end
  end

  @title = 'Auto-scaling groups'
  haml :index
end

get '/:group' do
  @regions = REGIONS.map do |region|

    instance_ids = autoscaling(region).describe_auto_scaling_groups(auto_scaling_group_names: [params[:group]]).auto_scaling_groups.map do |group|
      group.instances.map(&:instance_id)
    end.flatten #list of instance IDs for this group

    if instance_ids.empty?
      instances = []
    else
      instances = ec2(region).describe_instances(instance_ids: instance_ids).reservations.map(&:instances).flatten.map do |instance| #get instance details
        host = instance.public_dns_name
        {
          details:    instance,
          procs:      supervisord_procs(host),
          containers: cadvisor_containers(host),
        }
      end
    end

    { name: region, instances: instances }
  end

  @title = params[:group]
  haml :group
end
