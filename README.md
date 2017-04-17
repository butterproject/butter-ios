[Butter for iOS](https://github.com/butterproject/butter-ios/)
----

Watch free Movies on your iOS device, without any particular knowledge.

Visit the project's website at <http://butterproject.org>.

* [Continuous Integration](http://ci.butterproject.org/job/butter-ios/)
* [Issue Tracker](https://github.com/butterproject/butter-ios/issues)

## Community

Keep track of Butter development and community activity.

* Follow Butter on [Twitter](https://twitter.com/butterproject), [Facebook](https://www.facebook.com/ButterProject) and [Google+](https://plus.google.com/+butterproject).
* Read and subscribe to the [The Official Butter Blog](http://blog.butterproject.org).
* Join in discussions on the [Butter Forum](https://discuss.butterproject.org)
* Connect with us on IRC at `#butterproject` on freenode ([web access](http://webchat.freenode.net/?channels=butterproject))

## Getting Involved

Want to report a bug, request a feature, contribute or translate Butter? Check out our in-depth guide to [Contributing to Butter](CONTRIBUTING.md).

## Build Instructions ##

This project uses [CocoaPods](http://cocoapods.org/).

``` bash
$ git clone https://github.com/butterproject/butter-ios.git butter-ios
$ cd butter-ios/
$ pod install
$ open Butter.xcworkspace
```
Make sure you save classes to subdirectories like the file groups in Xcode to keep files organised.

## Versioning

For transparency and insight into our release cycle, and for striving to maintain backward compatibility, Butter will be maintained according to the [Semantic Versioning](http://semver.org/) guidelines as much as possible.

### Beta versions

Beta releases will be numbered with the following format:

`0.<major>.<minor>-<patch>`

### Stable versions

Releases will be numbered with the following format:

`<major>.<minor>.<patch>`


Constructed with the following guidelines:
* A new *major* release indicates a large change where backwards compatibility is broken.
* A new *minor* release indicates a normal change that maintains backwards compatibility.
* A new *patch* release indicates a bugfix or small change which does not affect compatibility.

## License

If you distribute a copy or make a fork of the project, you have to credit this project as source.

This program is free software: you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation, either version 3 of the License, or (at your option) any later version.

This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License for more details.

You should have received a copy of the GNU General Public License along with this program.  If not, see http://www.gnu.org/licenses/.

Note: some dependencies are external libraries, which might be covered by a different license compatible with the GPLv3. They are mentioned in NOTICE.md.

***

If you want to contact us: [hello@butterproject.org](mailto:hello@butterproject.org)

Copyright (c) 2014 Butter Foundation - Released under the [GPL V3 license](https://github.com/butterproject/butter-ios/blob/master/LICENSE.md).