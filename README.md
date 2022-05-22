# This is a autoscalable webserver with nlb in the front. 
It is designed to autoscale if the average cpu utilization is over 40%.
The min size is 1 and max is 2.

## How to start
* `sh start.sh plan` to see the terraform plan
* `sh start.sh apply` to create nlb + webserver
* `sh start.sh destroy` to remove
