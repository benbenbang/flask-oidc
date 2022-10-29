# flask-oidc

## Forked Version

This project is forked from [flask-oidc](https://github.com/puiterwijk/flask-oidc), and is now renamed **flask-providers-oidc**

This version uses `pyjwt` instead of `isdangerous`.

No need to change the import:

```python
from oidc import OpenIDConnect
...
```

## Original Readme

[OpenID Connect](https://openid.net/connect/) support for [Flask](http://flask.pocoo.org/).

[![image](https://img.shields.io/pypi/v/flask-oidc.svg?style=flat)](https://pypi.python.org/pypi/flask-oidc)

[![image](https://img.shields.io/pypi/dm/flask-oidc.svg?style=flat)](https://pypi.python.org/pypi/flask-oidc)

[![Documentation Status](https://readthedocs.org/projects/flask-oidc/badge/?version=latest)](http://flask-oidc.readthedocs.io/en/latest/?badge=latest)

[![image](https://img.shields.io/travis/puiterwijk/flask-oidc.svg?style=flat)](https://travis-ci.org/puiterwijk/flask-oidc)

This library should work with any standards compliant OpenID Connect provider.

It has been tested with:

-   [Google+ Login](https://developers.google.com/accounts/docs/OAuth2Login)
-   [Ipsilon](https://ipsilon-project.org/)

# Project status

This project is in active development.
