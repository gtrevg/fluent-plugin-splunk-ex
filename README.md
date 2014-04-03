# Splunk output plugin for Fluent event collector

## Overview

This plugin will send your fluentd logs to a splunk server.  It can send the data in either
key/value (k1=v1 k2=v2) or json format for easy splunk parsing.


## Installation

    gem install fluent-plugin-splunk-ex

## Configuration

    <match pattern>
      type splunk_ex
      host <splunk_host>   # default: localhost
      port <splunk_port>   # default: 9997
      use_time <boolean>   # default: false
      time_key <string>    # default: time
      format kv|json       # default: kv
    </match>

## Copyright

Copyright: Copyright (c) 2014 Trevor Gattis
License:  Apache License, Version 2.0


