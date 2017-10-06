# Sideload

A gem for copying (primarily config) files between different locations.
Supported is github (read-only), redis and the file system. The primary
use case for this is distributing a new configuration through a large
system.

It works by including this gem into every node on the system and invoking
the update process every 30 minutes or so. It then will start from the
outside in, copy the outer-most **valid** config down to the inner layers.

Put your configs on a github account's master. So this is the outer layer.
The next layer could be a network share, then redis, and then local file
storage. Assuming that your application ships with a config in the local file
system that works, this is the backup. It will try through all other layers
from the outside in and take care of copying it for availability. Through
this system you can minimize system crashes on a large scale, if the validation
in place is solid.

The example folder should teach you how it works.

## Installation

```bash
  gem install sideload
```
