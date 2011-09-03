# encoding=utf-8

import os

from redis import Redis

from flask import Flask, request, g
from flaskext.assets import Environment, Bundle
from flaskext.login import (LoginManager, current_user, login_required,
                            login_user, logout_user, AnonymousUser,
                            confirm_login, fresh_login_required)


app = Flask(__name__)
app.config.from_object('gcm.config.%s' % os.environ.get('GCM_CONFIG', 'production'))


assets = Environment(app)
assets.register('gcm', Bundle(
    'lib/modernizer-2.0.6.js',
    'lib/jquery-1.6.1.js', 
    'jquery-ui/jquery-ui-1.8.14.custom.js', 
    'lib/underscore.js', 
    'lib/backbone.js', 
    'js/auth.js', 
    'js/tumblr.js',
    'js/instagram.js',
    'js/gcm.js', 
    # filters='jsmin', 
    output='gen/gcm.js'))
    
assets.register('admin', Bundle(
    'lib/modernizer-2.0.6.js',
    'lib/jquery-1.6.1.js', 
    'jquery-ui/jquery-ui-1.8.14.custom.js', 
    'lib/underscore.js', 
    'lib/backbone.js', 
    'js/admin.js', 
    # filters='jsmin', 
    output='gen/admin.js'))

if not app.debug:
    from gcm.loggers import configure_logging
    configure_logging(app)

from gcm import helpers

@app.template_filter()
def timesince(value):
    return helpers.timesince(value)
    
@app.template_filter()
def linebreaks(value):
    return helpers.linebreaks(value)

@app.before_request
def connect_services():
    g.redis = Redis(host='localhost', port=6379, db=0)

@app.before_request
def set_globals():
    try:
        def file_string(path):
            return ''.join(file(path).read().splitlines()).strip()
        g.deploy = file_string(os.path.join(os.path.dirname(__file__), 'deploy'))
    except IOError, e:
        g.deploy = ''


from gcm.models import Person
from gcm.extensions import db
db.init_app(app)

login_manager = LoginManager()

AnonymousUser.json = {}
AnonymousUser.id = None
AnonymousUser.graph_id = None

login_manager.anonymous_user = AnonymousUser
# login_manager.login_view = ".login"
login_manager.login_message = u"This content is not available."

@login_manager.user_loader
def load_user(id):
    return Person.query.filter_by(id=int(id)).first()

login_manager.setup_app(app)

from gcm.views import *

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5066, debug=True)

