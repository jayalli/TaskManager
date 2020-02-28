from flask import Flask, render_template, url_for, request, redirect
from flask_sqlalchemy import SQLAlchemy
from datetime import datetime

app = Flask(__name__)

app.config[
    "SQLALCHEMY_DATABASE_URI"] = "sqlite:///test.db"  # tells app where the database is located (3 slashes = relative
# path)
# database stored in test.db file

db = SQLAlchemy(app)  # initialized database


class TODO(db.Model):  # this is the database
    id = db.Column(db.Integer, primary_key=True)  # primary key identifier can only be one
    content = db.Column(db.String(200),
                        nullable=False)  # cant be left , refers to the "input content in the 'index.html'"
    date_craeted = db.Column(db.DateTime, default=datetime.utcnow())


def __repr__(self):
    return "<Task %r>" % self.id


@app.route('/', methods=['POST', 'GET'])  # allows us to send and get data from our db
def index():
    if request.method == 'POST':  # grabs task and puts it in the database
        task_content = request.form['content']
        new_task = TODO(content=task_content)  # TODO

        try:
            db.session.add(new_task)
            db.session.commit()
            return redirect('/')
        except:
            return 'There was an issue passing your task'
    else:
        tasks = TODO.query.order_by(  # query goes iterates through everything??
            TODO.date_craeted).all()  # looks at all the database content in order created in and returns all of them
        # or can do(.first())
        return render_template(
            'index.html', tasks=tasks)  # prints whats in the index.html file as oppose to before with just a string


@app.route('/delete/<int:id>')  # new rout for new command use the id because it has primary key that cant be duplicated
def delete(id):
    task_to_delete = TODO.query.get_or_404(id)  # gets task by id and if it doesnt exist it 404's it

    try:
        db.session.delete(task_to_delete)
        db.session.commit()
        return redirect('/')  # redirect to homepage
    except:
        return 'There was a problem deleting the task'


@app.route('/update/<int:id>', methods=['GET', 'POST'])
def update(id):
    task = TODO.query.get_or_404(id)
    if request.method == 'POST':  # grabs task and puts it in the database
        task.content = request.form['content']

        try:
            db.session.commit()
            return redirect('/')
        except:
            return "There was an issue with the update"
    else:
        return render_template('update.html', task=task)


if __name__ == '__main__':
    app.run(debug=True)
