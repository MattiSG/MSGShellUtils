A set of shell script utils
===========================

A compilation of functions, either by me or found on the web, that centralize common functionalities needed in setup, install or cleanup scripts.

Rationale
---------

Funnier languages could do the same stuff while being more programmer-friendly, but you might not want your fellow developers to install this Node / Ruby / Python lib just to test your project written in a different environment  :)
The shell being the lowest common denominator to all flavors of environments (Windows without Cygwin is already an outcast in the kind of projects where you want cross-platform setup scripts).

Architecture
------------

The functions are stored in files by category.

* `ui.sh`: anything that enhances CLI;
* `paths.sh`: utils for working with paths;
* 

License
-------

MIT for stuff written by me, other licenses as given by their original developers in the comments above the functions. Usually so little code that no one ever bothered licensing it at all  ;)
Would be nice if you credited me (or the original author) when including files in your projects.
