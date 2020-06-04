##!/usr/bin/env puma

{% from "lagotto/map.jinja" import props with context %}

# Lock thread usage to a constant value.
thread_count = {{ props.get('puma_threads') }}
threads thread_count, thread_count

environment "{{ props.get('rails_env') }}"

prune_bundler

preload_app!

rackup "{{ props.get('app_root') }}/current/config.ru"

pidfile "{{ props.get('app_root') }}/shared/tmp/pids/puma.pid"

state_path "{{ props.get('app_root') }}/shared/tmp/pids/puma.state"

stdout_redirect "{{ props.get('app_root') }}/shared/log/lagotto_access.log",
                "{{ props.get('app_root') }}/shared/log/lagotto_error.log",
                true

bind "unix://{{ props.get('app_root') }}/shared/tmp/sockets/puma.sock"

workers {{ props.get('puma_workers') }}

on_restart do
  puts 'Refreshing Gemfile'
  ENV["BUNDLE_GEMFILE"] = "{{ props.get('app_root') }}/current/Gemfile"
end
