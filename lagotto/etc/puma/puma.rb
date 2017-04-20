##!/usr/bin/env puma

# Lock thread usage to a constant value.
thread_count = {{ pillar['lagotto']['puma']['threads'] }}
threads thread_count, thread_count

environment "{{ pillar['lagotto']['rails_env'] }}"

prune_bundler

preload_app!

rackup "{{ pillar['lagotto']['deploy']['app_root'] }}/current/config.ru"

pidfile "{{ pillar['lagotto']['deploy']['app_root'] }}/shared/tmp/pids/puma.pid"

state_path "{{ pillar['lagotto']['deploy']['app_root'] }}/shared/tmp/pids/puma.state"

stdout_redirect "{{ pillar['lagotto']['deploy']['app_root'] }}/shared/log/lagotto_access.log",
                "{{ pillar['lagotto']['deploy']['app_root'] }}/shared/log/lagotto_error.log",
                true

bind "unix://{{ pillar['lagotto']['deploy']['app_root'] }}/shared/tmp/sockets/puma.sock"

workers {{ pillar['lagotto']['puma']['workers'] }}

on_restart do
  puts 'Refreshing Gemfile'
  ENV["BUNDLE_GEMFILE"] = "{{ pillar['lagotto']['deploy']['app_root'] }}/current/Gemfile"
end
