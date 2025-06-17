# Placeholders

The framework has set of parameters that can be used in hte `Source Query` of the `Parameters`. These placeholder will be replace on runtime with current available infromation. These place holder can help with creating incremantal loading of dataset if the `source`-system / data-provider would allow this.

## Avialable Placeholder

> ***dt_previous_stand*** : Datatime '***previous***' stand, this is the MAX datetime of target dataset in over the columns ***meta_dt_valid_from*** and ***meta_dt_valid_till*** hereby excluding values greater then '9999-12-31'
<br>usage: "<@dt_previous_stand>"

> ***dt_current_stand*** : Datetime '***Current**' stand, this is the datetime of the moment the data pipeline is running.
<br>usage: "<@dt_current_stand>"

> ***ni_previous_epoch*** : # '***previous***' Epoch, this ***dt_previous_stand*** converted into epoch-format.
<br>usage: "<@ni_previous_epoch>"

> ***ni_current_epoch*** : # '***Current***' Epoch, this ***dt_current_stand*** converted into epoch-format.
<br>usage: "<@ni_current_epoch>"


### Epoch

Technical Explanation
Epoch Start:
The epoch begins at 00:00:00 UTC on January 1, 1970 (not counting leap seconds).

Epoch Time Representation:
Time is represented as a single integer (or sometimes a floating-point number if sub-second precision is needed), which counts the total number of seconds since the epoch.

For example:<br>
````
0          → Jan 1, 1970, 00:00:00 UTC
1625097600 → Jul 1, 2021, 00:00:00 UTC
````