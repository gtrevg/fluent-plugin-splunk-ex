[![Build Status](https://travis-ci.org/gtrevg/fluent-plugin-splunk-ex.svg?branch=master)](https://travis-ci.org/gtrevg/fluent-plugin-splunk-ex)

## Overview

This plugin will send your fluentd logs to a splunk server.  It can send the data in either
key/value (k1=v1 k2=v2) or json format for easy splunk parsing.


## Installation

    gem install fluent-plugin-splunk-ex

## Configuration

### Plugin

    <match pattern>
      type splunk_ex
      host <splunk_host>   # default: localhost
      port <splunk_port>   # default: 9997
      use_time <boolean>   # default: false
      time_key <string>    # default: time
      format kv|json       # default: kv
    </match>

### Splunk

Because the plugin will batch send data to Splunk, you'll want to update your `apps/search/local/props.conf`
file to specify that Splunk should split on newlines as the kv & json formats will not contain any newlines
within the individual log data.  The value to set is:

    SHOULD_LINEMERGE = false
    
Additionally, you may want to open up a special TCP port just for the FluentD logs.  To do that, go to
`Manager -> Data Inputs -> TCP -> New`.  Then decide the following:

* Port
* Source Name
* Source Type
* Index ( default works well )

After enabling these settings, you'll be able to see your fluentd logs appear in your Splunk search interface.
The JSON format will automagically be parsed and indexed based on the keys passed in.


## Copyright

Copyright (c) 2014 Trevor Gattis

## License

Apache License, Version 2.0


