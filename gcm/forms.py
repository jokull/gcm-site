# encoding=utf-8

import urlparse, re

from flaskext.fungiform import (Form, IntegerField, TextField, 
    DateField, Multiple, Mapping, BooleanField, 
    ValidationError, ChoiceField, widgets)


class TwitterNameField(TextField):
    
    _RE = re.compile(r'^([A-Za-z0-9_]+)$')
    
    def convert(self, value):
        if value:
            value = value.lstrip(u'@')
            if self._RE.match(value) is None:
                raise ValidationError(u'Lítur ekki út fyrir að vera Twitter nafn')
        return super(TwitterNameField, self).convert(value)

class URLField(TextField):
    """Adapted from django.forms.fields.URLField """
    def convert(self, value):
        if value:
            url_fields = list(urlparse.urlsplit(value))
            if not url_fields[0]:
                # If no URL scheme given, assume http://
                url_fields[0] = 'http'
            if not url_fields[1]:
                # Assume that if no domain is provided, that the path segment
                # contains the domain.
                url_fields[1] = url_fields[2]
                url_fields[2] = ''
                # Rebuild the url_fields list, since the domain segment may now
                # contain the path too.
                value = urlparse.urlunsplit(url_fields)
                url_fields = list(urlparse.urlsplit(value))
            if not url_fields[2]:
                # the path portion may need to be added before query params
                url_fields[2] = '/'
            value = urlparse.urlunsplit(url_fields)
        return super(URLField, self).convert(value)

class SignupForm(Form):
    
    csrf_protected = False
    
    blog_url = URLField(u'Blogg', required=False)
    twitter_name = TwitterNameField(u'Twitter', required=False)

