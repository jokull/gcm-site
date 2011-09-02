# encoding=utf-8

import hashlib, datetime, itertools, locale

from facegraph.graph import Graph

from flask import url_for, g, current_app
from flaskext.login import current_user

from gcm.classtools import cached_property
from gcm.extensions import db

from .types import DenormalizedText

locale.setlocale(locale.LC_ALL, "is_IS.UTF-8") # To print nice dates

class Person(db.Model):
    
    id = db.Column(db.Integer, primary_key=True)
    created = db.Column(db.DateTime, default=datetime.datetime.now)
    
    email = db.Column(db.String(250), index=True)
    kennitala = db.Column(db.String, index=True)
    
    graph_access_token = db.Column(db.String, default='')
    graph_id = db.Column(db.String, default='', index=True)
    
    name = db.Column(db.String(255), nullable=False)
    blog_url = db.Column(db.String(255), nullable=False, default='')
    twitter_name = db.Column(db.String(255), nullable=False, default='')
    
    friends = db.Column(DenormalizedText(coerce=str))
    
    def __init__(self, **kwargs):
        for key, value in kwargs.iteritems():
            setattr(self, key, value)
        self.friends = self.friends or set()
    
    @property
    def picture_url(self):
        return 'http://graph.facebook.com/%s/picture?type=square' % self.graph_id

    def is_friend(self, person):
        return person.graph_id == self.graph_id or \
            person.graph_id in self.friends
    
    """
    Methods Flask-Login expects
    """
    
    def is_authenticated(self):
        return True
    
    def is_active(self):
        return True
    
    def is_anonymous(self):
        return False
    
    def get_id(self):
        return unicode(self.id)
    
    def get_graph(self):
        return Graph(self.graph_access_token)

    def get_friends(self):
        return Person.query.filter(Person.graph_id.in_(self.friends))
    
    @classmethod
    def create(cls, clean_data):
        
        graph_access_token = clean_data.pop('graph_access_token')
        person = cls(**dict(clean_data))
        person.graph_access_token = graph_access_token
        
        return person
    
    @cached_property
    def json(self):
        return dict(id=self.id,
                    graph_id=self.graph_id,
                    picture_url=self.picture_url,
                    name=self.name,
                    blog_url=self.blog_url,
                    twitter_name=self.twitter_name)









