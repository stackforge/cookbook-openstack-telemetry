# encoding: UTF-8
require_relative 'spec_helper'

describe 'openstack-telemetry::identity_registration' do
  before do
    telemetry_stubs
    @chef_run = ::ChefSpec::Runner.new ::UBUNTU_OPTS
    @chef_run.converge 'openstack-telemetry::identity_registration'
  end

  it 'registers service tenant' do
    expect(@chef_run).to create_tenant_openstack_identity_register(
      'Register Service Tenant'
    ).with(
      auth_uri: 'http://127.0.0.1:35357/v2.0',
      bootstrap_token: 'bootstrap-token',
      tenant_name: 'service',
      tenant_description: 'Service Tenant'
    )
  end

  it 'registers service user' do
    expect(@chef_run).to create_user_openstack_identity_register(
      'Register Service User'
    ).with(
      auth_uri: 'http://127.0.0.1:35357/v2.0',
      bootstrap_token: 'bootstrap-token',
      tenant_name: 'service',
      user_name: 'ceilometer',
      user_pass: 'ceilometer-pass'
    )
  end

  it 'grants admin role to service user for service tenant' do
    expect(@chef_run).to grant_role_openstack_identity_register(
      "Grant 'admin' Role to Service User for Service Tenant"
    ).with(
      auth_uri: 'http://127.0.0.1:35357/v2.0',
      bootstrap_token: 'bootstrap-token',
      tenant_name: 'service',
      user_name: 'ceilometer',
      role_name: 'admin',
      action: [:grant_role]
    )
  end

  it 'registers metering service' do
    expect(@chef_run).to create_service_openstack_identity_register(
      'Register Metering Service'
    ).with(
      auth_uri: 'http://127.0.0.1:35357/v2.0',
      bootstrap_token: 'bootstrap-token',
      service_name: 'ceilometer',
      service_type: 'metering'
    )
  end

  it 'registers metering endpoint' do
    expect(@chef_run).to create_endpoint_openstack_identity_register(
      'Register Metering Endpoint'
    ).with(
      auth_uri: 'http://127.0.0.1:35357/v2.0',
      bootstrap_token: 'bootstrap-token',
      service_type: 'metering',
      endpoint_region: 'RegionOne',
      endpoint_adminurl: 'http://127.0.0.1:8777',
      endpoint_internalurl: 'http://127.0.0.1:8777',
      endpoint_publicurl: 'http://127.0.0.1:8777'
    )
  end

  it 'overrides metering endpoint region' do
    @chef_run = ::ChefSpec::Runner.new ::UBUNTU_OPTS do |n|
      n.set['openstack']['telemetry']['region'] = 'meteringRegion'
    end
    @chef_run.converge 'openstack-telemetry::identity_registration'

    expect(@chef_run).to create_endpoint_openstack_identity_register(
      'Register Metering Endpoint'
    ).with(
      endpoint_region: 'meteringRegion'
    )
  end
end
