# encoding=utf-8

import urlparse, re

from flaskext.fungiform import (Form, IntegerField, TextField, 
    DateField, Multiple, Mapping, BooleanField, 
    ValidationError, ChoiceField, widgets)

twitter_username_re = re.compile(r'([A-Za-z0-9_]+)')

def is_twitter_username(form, value):
    value = value.lstrip('@')
    if twitter_username_re.match(value) is None:
        raise ValidationError, u'Lítur ekki út fyrir að vera Twitter nafn'
    return value

class URLField(TextField):
    def convert(self, value):
        value = super(URLField, self).convert(value)
        if not value.startswith('http://') or value.startswith('https://'):
            value = 'http://%s' % value
        return value

class SignupForm(Form):
    
    csrf_protected = False
    
    blog_url = URLField(u'Blogg', required=False)
    twitter_name = TextField(u'Twitter', required=False, 
                                         validators=[is_twitter_username])

