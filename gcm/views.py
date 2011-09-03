# encoding=utf-8

import datetime, json, itertools, uuid

from flask import (request, flash, url_for, redirect, current_app,
                   render_template, abort, session, jsonify, g)
    
from flaskext.login import (current_user, login_required, 
                            logout_user, login_user)

from facegraph.graph import Graph

from .app import app, db
from .models import Person
from .auth import requires_basic_auth
from .forms import SignupForm


@app.route('/connect', methods=['POST'])
def connect():

    def has_keys(d, keys):
        return all([(k in d) for k in keys])
    
    if not has_keys(request.form, ('uid', 'access_token')):
        abort(403)
    
    graph = Graph(request.form['access_token']).me()
    
    graph_id = request.form.get('uid')
    access_token = request.form.get('access_token')
    
    person = Person.query.filter_by(graph_id=graph_id).first()
    
    if person is None:
        clean_data = dict(name=graph.name,
                          graph_id=graph_id,
                          graph_access_token=access_token)
        person = Person.create(clean_data)

    person.friends = [f.id for f in graph.friends().data]
    
    db.session.add(person)
    db.session.commit()
        
    if not login_user(person, remember=True):
        return jsonify(error=u'inactive')
    
    response = person.json
    response['friends'] = [p.json for p in person.get_friends()]
    
    return jsonify(**response)


@app.route('/', methods=['GET'])
def gcm():
    
    js = dict(
        graph_id=current_app.config['GRAPH_API'][0],
        instagram_id=current_app.config['INSTAGRAM_API'][0],
        tumblr_id=current_app.config['TUMBLR_API'][0],
        routes={
            'static': url_for('static', filename="", _external=True),
            'connect': url_for('connect'),
            'signup': url_for('signup'),
        }
    )
    
    form = SignupForm(action=url_for('signup')).as_widget()
        
    return render_template('gcm.html', **locals())


@app.route('/signup', methods=['POST'])
def signup():
    form = SignupForm()
    if form.validate():
        current_user.blog_url = form.data['blog_url']
        current_user.twitter_name = form.data['twitter_name']
        db.session.add(current_user)
        db.session.commit()
        response = current_user.json
    else:
        response = dict(errors=dict(form.errors))
    return jsonify(**response)


@app.route('/admin', methods=['GET'])
@requires_basic_auth
def admin():
    return render_template('admin.html',
        js=dict(
            questions=[q.json for q in Question.query.all()],
        )
    )




