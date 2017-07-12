# This file is managed by SALT. *Do Not Modify*

#
# GROUPS
#
#saved       = Group.where(name: 'saved').first_or_create(title: 'Saved')
#cited       = Group.where(name: 'cited').first_or_create(title: 'Cited')
#discussed   = Group.where(name: 'discussed').first_or_create(title: 'Discussed')
#viewed      = Group.where(name: 'viewed').first_or_create(title: 'Viewed')
#other       = Group.where(name: 'other').first_or_create(title: 'Other')
#recommended = Group.where(name: 'recommended').first_or_create(title: 'Recommended')

#
# SOURCES
#
#Source.delete_all   # clean-slate 

# Counter
#counter_cfg = OpenStruct.new
#counter_cfg['url'] = 'http://{{ camoflauge }}/counter/services/rest?method=usage.stats&doi=%{doi}'
#counter_cfg['job_batch_size']      = 200
#counter_cfg['batch_time_interval'] = 3600
#counter_cfg['rate_limiting']       = 200000
#counter_cfg['wait_time']           = 300
#counter_cfg['staleness_week']      = 86400
#counter_cfg['staleness_month']     = 86400
#counter_cfg['staleness_year']      = 86400
#counter_cfg['staleness_all']       = 86400
#counter_cfg['timeout']             = 30
#counter_cfg['max_failed_queries']  = 1000
#counter_cfg['max_failed_query_time_interval'] = 86400
#counter_cfg['disable_delay']       = 10
#counter_cfg['workers']             = 50
#counter_cfg['cron_line']           = '30 13 * * *'
#counter_cfg['priority']            = 2
#counter_cfg['queue']               = 'high'
#counter_cfg['url_private'] = 'http://{{ camoflauge }}/counter/services/rest?method=usage.stats&doi=%{doi}'

#counter = Counter.where(name: 'counter').first_or_create(
  #:type        => 'Counter',
  #:name        => 'counter',
  #:title       => 'Counter',
  #:config      => counter_cfg,
  #:group_id    => viewed.id,
  #:private     => 0,
  #:state_event => 'inactivate',
  #:description => '',
  #:queueable   => 0,
  #:eventable   => 0)

#
# PUBLISHER_OPTIONS 
#
#crossref_po_cfg = OpenStruct.new
#crossref_po_cfg['username'] = 'plos'
#crossref_po_cfg['password'] = 'plos1'

#crossref_po = PublisherOption.where(source_id: crossref.id).where(publisher_id: 340).first_or_create(
  #:publisher_id => 340,
  #:source_id => crossref.id,
  #:config => crossref_po_cfg)
