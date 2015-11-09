#!/bin/bash

set -e
set -u

cd /home/ubuntu/events
/home/ubuntu/.rbenv/shims/ruby bin/fetch_env.rb
touch .aws_init_complete
chmod 777 .aws_init_complete