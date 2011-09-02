# encoding=utf-8

import datetime, json, itertools

from flask import request, current_app

from urlparse import urlparse, parse_qs

from instagram import InstagramAPI
from instagram.models import ApiModel

TAG_NAME = 'gcm'
PAGE_COUNT = 5


def get_photos(max_tag_id=None):
    
    client_id, client_secret = current_app.config['INSTAGRAM_API']
    
    api = InstagramAPI(client_id=client_id, 
                       client_secret=client_secret, 
                       redirect_uri=request.url)
                       
    data, next_url = api.tag_recent_media(tag_name=TAG_NAME, 
                                          count=PAGE_COUNT, 
                                          max_tag_id=max_tag_id)
    
    def _to_dict(obj):
        d = dict()
        if not isinstance(obj, dict):
            obj = obj.__dict__
        for key, value in obj.iteritems():
            if isinstance(value, (ApiModel, dict)):
                d[key] = _to_dict(value)
            elif isinstance(value, list):
                d[key] = map(unicode, value)
            else:
                d[key] = unicode(value)
        return d
    
    qs = urlparse(next_url).query
    max_tag_id = parse_qs(qs).get('max_tag_id', [None])[0]
    
    photos = [_to_dict(obj) for obj in data]
    
    return photos, max_tag_id


